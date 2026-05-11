// ============================================================
// TEST 2: Giới hạn bộ nhớ In-memory Sort 100MB mỗi Stage
// Bài toán: Tính điểm trung bình từng sản phẩm, sắp xếp giảm dần
// Minh họa: allowDiskUse:false -> lỗi nếu vượt 100MB
//           allowDiskUse:true  -> tự động spill to disk như Oracle
// ============================================================

print("============================================================");
print(" CASE STUDY 2: IN-MEMORY SORT LIMIT (100MB per Stage)");
print(" Query: Diem trung binh san pham, sap xep giam dan");
print("============================================================");

// --- Bước 1: Kết quả thực tế với allowDiskUse:true (an toàn) ---
print("\n--- [KET QUA THUC TE: allowDiskUse = true] ---");
db.reviews.aggregate([
    {
        $group: {
            _id: "$product_id",
            avgScore:  { $avg: "$rating.score" },
            totalReviews: { $sum: 1 },
            maxScore:  { $max: "$rating.score" },
            minScore:  { $min: "$rating.score" }
        }
    },
    { $sort: { avgScore: -1 } },
    { $limit: 10 }
], { allowDiskUse: true }).forEach(doc => printjson(doc));

// --- Bước 2: Execution plan bình thường ---
print("\n--- [EXPLAIN PLAN: allowDiskUse = true] ---");
print("Tim 'usedDisk: true' trong executionStats neu data > 100MB");

printjson(
    db.reviews.explain("executionStats").aggregate([
        { $group: { _id: "$product_id", avgScore: { $avg: "$rating.score" } } },
        { $sort: { avgScore: -1 } }
    ], { allowDiskUse: true })
);

// --- Bước 3: Cố tình tắt allowDiskUse -> trigger lỗi 100MB ---
print("\n--- [DEMO LOI 100MB: allowDiskUse = false] ---");
print("Neo data > 100MB, MongoDB se nem loi:");
print("'Sort exceeded memory limit of 104857600 bytes'");
print("(Tuong tu MongoDB se bao loi khi sort tren tap data lon)");

try {
    db.reviews.aggregate([
        { $sort: { "rating.score": -1 } }
    ], { allowDiskUse: false }).toArray();
    print("OK - data nho hon 100MB, khong can spill to disk");
} catch(e) {
    print("LOI (nhu ky vong voi data lon):");
    print(e.message);
}

// --- Bước 4: So sánh với MongoDB có index hỗ trợ sort ---
print("\n--- [SO SANH: Co Index tren rating.score -> Khong can sort] ---");
print("Neu co index -> MongoDB bao qua phan sort hoan toan (Index already sorted)");

printjson(
    db.reviews.explain("executionStats").aggregate([
        { $sort: { "rating.score": -1 } },
        { $limit: 5 }
    ])
);

// --- Bước 5: Aggregation Pipeline - minh họa stage chaining ---
print("\n--- [AGGREGATION PIPELINE: $match -> $group -> $sort] ---");
print("MongoDB Planner tu dong keo $match len truoc $sort de dung Index");

printjson(
    db.reviews.explain("executionStats").aggregate([
        { $match: { "rating.score": { $gte: 4 } } },
        { $group: { _id: "$product_id", count: { $sum: 1 } } },
        { $sort:  { count: -1 } }
    ], { allowDiskUse: true })
);

print("\n--- [PHAN TICH] ---");
print("> Oracle: External Sort xas ra TEMP tablespace, khong co gioi han cung");
print("> MongoDB: Gioi han cung 100MB/stage, can allowDiskUse:true de spill");
print("> Index tren sort field: ca 2 deu tranh duoc phan sort (da sap xep san)");
print("> MongoDB 6.0+ tu dong spill-to-disk, khong can set allowDiskUse thu cong");
