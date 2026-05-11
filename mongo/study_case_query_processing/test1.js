// ============================================================
// TEST 1: Bypass JOIN nhờ Embedding + Aggregation Pipeline
// Bài toán: Lấy order_id + tên sản phẩm của đơn hàng đã giao
// Minh họa: Document nhúng sẵn items -> không cần $lookup
//           So sánh plan khi dùng $lookup vs khi dùng embedded
// ============================================================

print("============================================================");
print(" CASE STUDY 1: BYPASS JOIN & AGGREGATION PIPELINE");
print(" Query: Don hang da thanh toan -> ten san pham");
print("============================================================");

// --- Bước 1: Kết quả thực tế dùng $lookup (giống JOIN của Oracle) ---
print("\n--- [CACH 1: Dung $lookup - tuong duong JOIN] ---");
print("Plan se hien thi: IXSCAN -> FETCH -> $lookup (Nested-Loop Join)");

db.orders.aggregate([
    { $match: { status: "delivered" } },
    {
        $lookup: {
            from: "order_details",
            localField: "_id",
            foreignField: "order_id",
            as: "details"
        }
    },
    { $unwind: "$details" },
    {
        $lookup: {
            from: "products",
            localField: "details.product_id",
            foreignField: "_id",
            as: "product"
        }
    },
    { $unwind: "$product" },
    {
        $project: {
            _id: 0,
            order_id: "$_id",
            product_name: "$product.name",
            status: 1
        }
    }
]).forEach(doc => printjson(doc));

// --- Bước 2: Execution plan của $lookup ---
print("\n--- [EXPLAIN PLAN: $lookup approach] ---");
printjson(
    db.orders.explain("executionStats").aggregate([
        { $match: { status: "delivered" } },
        {
            $lookup: {
                from: "order_details",
                localField: "_id",
                foreignField: "order_id",
                as: "details"
            }
        }
    ])
);

// --- Bước 3: Kết quả dùng Embedded (không cần $lookup) ---
print("\n--- [CACH 2: Dung Embedded Document - Bypass JOIN hoan toan] ---");
print("Neu items duoc nhung san trong orders -> khong can $lookup nao ca");
print("Plan: IXSCAN tren status -> FETCH document -> xong");

db.orders.find(
    { status: "delivered" },
    { _id: 1, status: 1, "items.product_name": 1, "items.quantity": 1 }
).forEach(doc => printjson(doc));

// --- Bước 4: So sánh plan giữa 2 cách ---
print("\n--- [EXPLAIN PLAN: Embedded approach - tinh gon hon] ---");
printjson(
    db.orders.find(
        { status: "delivered" },
        { _id: 1, "items.product_name": 1 }
    ).explain("executionStats")
);

print("\n--- [PHAN TICH] ---");
print("> CACH 1 ($lookup): Nested-Loop Join, can doc nhieu collection");
print("> CACH 2 (Embedded): Chi IXSCAN + FETCH 1 collection, khong JOIN");
print("> totalKeysExamined = nReturned = 100% hit rate -> toi uu nhat");
print("> Oracle phai JOIN 3 bang -> MongoDB Embedding loai bo hoan toan chi phi nay");
