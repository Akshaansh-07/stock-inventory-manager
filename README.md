# NET4207 – Stock Inventory Manager
AKSHAANSH GUPTA
I26042580

## 1. Project Overview
The Stock Inventory Manager is a Flutter mobile application developed for a small retailer. It allows users to add stock items, store inventory records in Firebase Cloud Firestore, retrieve saved records and search inventory efficiently.

## 2. Technologies Used
- Flutter and Dart
- Firebase Cloud Firestore
- Android Studio
- Git and GitHub

## 3. Setup and Installation
1. Install Flutter SDK and Android Studio.
2. Clone this repository:
   `git clone https://github.com/YOUR_USERNAME/stock-inventory-manager.git`
3. Open the project in Android Studio.
4. Install dependencies using `flutter pub get`.
5. Ensure Firebase is configured using the lecturer-provided Firebase project.
6. Firebase Project ID: `akshaansh-20d47`
7. Run the application using `flutter run`.

Required packages:
- `firebase_core`
- `cloud_firestore`

## 4. Firestore Data Schema
The application uses the `stockItems` collection with automatically generated document IDs.

| Field | Type | Description |
|---|---|---|
| sku | String | Stock code (STK-101) |
| itemName | String | Minimum 3 characters |
| category | String | Electronics, Stationery, Hardware or Grocery |
| quantity | Integer | Zero or above |
| unitPrice | Number | Greater than RM0 |
| reorderLevel | Integer | Zero or above |
| createdAt | Timestamp | Server-generated timestamp |

## 5. Validation and Search
The stock form validates all six required inputs before saving. SKU must follow the STK- followed by three digits format. Item names must contain at least three characters. Quantity and reorder level must be non-negative whole numbers, while price must be positive. Category selection is compulsory.

The inventory screen retrieves records from Firestore. Keyword searching supports partial, case-insensitive matches against item names and SKUs. Users can filter by category, display low-stock items where quantity is less than or equal to reorder level, and combine filters. Results can be sorted by quantity in ascending or descending order. Clear Filters restores the complete inventory list.

## 6. Test Log

| Test | Expected Result | Actual Result |
|---|---|---|
| Submit blank or invalid form | Field-level errors; no Firestore document created | To be recorded |
| Save and retrieve STK-101, STK-102 and STK-103 | Three records saved and retrieved with correct values | To be recorded |
| Search "mouse" with Electronics and Low Stock enabled | Only STK-103 appears | To be recorded |

## 7. Evidence
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/791cd3f6-510a-4072-90a8-94417922b80d" />
<img width="1917" height="1079" alt="image" src="https://github.com/user-attachments/assets/d6d59437-011c-4ce3-8e99-406864d46e6a" />
<img width="1915" height="1074" alt="image" src="https://github.com/user-attachments/assets/c2414f3b-d68a-4775-bacd-3482a975ba3e" />
<img width="1917" height="1076" alt="image" src="https://github.com/user-attachments/assets/d37e6781-98c2-41f1-b0d1-10b97053cd17" />
<img width="1919" height="1077" alt="image" src="https://github.com/user-attachments/assets/64d2a44e-8b4b-4c4e-896b-d38602fd01aa" />
<img width="1919" height="1079" alt="image" src="https://github.com/user-attachments/assets/b0acb6c8-ffbe-41b6-89d5-7a1546c152b3" />


## 8. Submission
The Flutter source code, README documentation and evidence screenshots are submitted through GitHub. Firebase Cloud Firestore is used to store inventory records.
