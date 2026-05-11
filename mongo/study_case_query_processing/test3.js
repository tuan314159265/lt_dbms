// ============================================================
// TEST 3: Query Planner - Plan Racing (MongoDB) vs CBO (Oracle)
// Bài toán: Tìm đơn hàng theo status
// Minh họa: MongoDB cho các plan chạy đua (Racing) để chọn winner
//           rejectedPlans[] chứng minh quá trình này
//           Oracle CBO dựa trên Statistics/Histogram để chọn plan
// ============================================================

print("============================================================");
print(" CASE STUDY 3: QUERY PLANNER - PLAN RACING vs CBO");
print(" MongoDB: Plans chay dua -> chon winner");
print(" Oracle:  CBO dua tren Statistics + Histogram");
print("============================================================");

// --- Bước 1: Plan Racing với status phổ biến (delivered) ---
print("\n--- [PLAN RACING: status = 'delivered' (pho bien)] ---");
print("Ky vong: MongoDB Racing giua IXSCAN va COLLSCAN");
print("Winner: tuy vao selectivity - neu delivered la da so -> COLLSCAN co the thang");

var plan1 = db.orders.find({ status: "delivered" }).explain("allPlansExecution");
print("Winning Plan:");
printjson(plan1.queryPlanner.winningPlan);
print("\nRejected Plans:");
printjson(plan1.queryPlanner.rejectedPlans);
print("\nExecution Stats (Winner):");
printjson(plan1.executionStats);

// --- Bước 2: Plan Racing với status hiếm (cancelled) ---
print("\n--- [PLAN RACING: status = 'cancelled' (hiem)] ---");
print("Ky vong: IXSCAN thang vi selectivity cao (it ban ghi)");

var plan2 = db.orders.find({ status: "cancelled" }).explain("allPlansExecution");
print("Winning Plan:");
printjson(plan2.queryPlanner.winningPlan);
print("\nRejected Plans:");
printjson(plan2.queryPlanner.rejectedPlans);
print("\nnReturned:", plan2.executionStats.nReturned,
      "| totalDocsExamined:", plan2.executionStats.totalDocsExamined);

// --- Bước 3: Multi-field query - Index Intersection ---
print("\n--- [INDEX INTERSECTION: Ket hop nhieu index don] ---");
print("Neu khong co composite index, MongoDB co the ket hop 2 index don:");
print("Eg: index tren {status} + index tren {created_at} -> Intersection");

var plan3 = db.orders.find({
    status: "delivered",
    total_amount: { $gt: 100000 }
}).explain("allPlansExecution");

print("Winning Plan:");
printjson(plan3.queryPlanner.winningPlan);
print("\nRejected Plans (so sanh voi COLLSCAN va cac index don khac):");
printjson(plan3.queryPlanner.rejectedPlans);

// --- Bước 4: Pipeline Stage Reordering (Heuristics) ---
print("\n--- [HEURISTICS: Pipeline Stage Reordering] ---");
print("Developer viet $sort truoc $match - MongoDB tu dong dao nguoc lai");
print("De tan dung Index tren status truoc khi sort");

var plan4 = db.orders.explain("queryPlanner").aggregate([
    { $sort:  { total_amount: -1 } },   // developer viet sort truoc
    { $match: { status: "delivered" } } // MongoDB se keo match len truoc
]);
print("Actual stages sau khi Optimizer sap xep lai:");
printjson(plan4.queryPlanner);

// --- Bước 5: So sánh với Oracle CBO approach ---
print("\n--- [SO SANH VOI ORACLE CBO] ---");
print("Oracle CBO: Dua tren Statistics (so luong ban ghi, histogram phan phoi)");
print("  -> SELECT status, COUNT(*) FROM orders GROUP BY status;");
print("  -> CBO biet 'delivered' = 60%, 'cancelled' = 5%");
print("  -> Tu dong chon Full Scan cho 'delivered', Index Scan cho 'cancelled'");
print("");
print("MongoDB Planner: Chay dua thuc nghiem (Racing) tren RAM");
print("  -> Cho nhieu plan chay song song toi khi 1 plan tra ve ket qua dau tien");
print("  -> Luu cache plan thang cuoc -> dung lai cho query tuong tu");
print("  -> Cache bi xoa khi: schema thay doi, index moi, server restart");

// --- Bước 6: Xem cache trạng thái hiện tại ---
print("\n--- [PLAN CACHE HIEN TAI] ---");
db.orders.getPlanCache().list().forEach(entry => {
    print("Query Shape:", JSON.stringify(entry.createdFromQuery));
    print("Is Active:", entry.isActive);
    print("---");
});

print("\n--- [PHAN TICH] ---");
print("> MongoDB rejectedPlans[] = bang chung Plan Racing da xay ra");
print("> Oracle Histogram = CBO biet phan phoi du lieu -> chon plan khong can chay thu");
print("> MongoDB Plan Cache = ghi nho ket qua Racing -> tai su dung");
print("> Oracle Adaptive Plans = doi plan NGAY KHI DANG CHAY neu uoc tinh sai");
print("> => Oracle manh hon voi complex multi-table queries");
print("> => MongoDB nhanh hon voi single-collection document lookup");
