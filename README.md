# 🚀 Salesforce CSV Data Import Wizard (LWC)

A dynamic **Data Import Tool built using Lightning Web Components (LWC) and Apex** that allows users to upload CSV files, map fields, and insert records into any Salesforce object — similar to a mini Data Loader.

---

## 📌 Features

- 📁 Upload CSV file
- 🔍 Automatically read CSV headers and data
- 🧠 Dynamic object selection (only creatable objects)
- 🔗 Field mapping (CSV → Salesforce fields)
- ⚡ Dynamic record insertion using Apex
- 🧾 Supports multiple records (bulk insert)

---

## 🏗️ Tech Stack

- **Frontend:** Lightning Web Components (LWC)
- **Backend:** Apex
- **Platform:** Salesforce


---

## 🎥 Demo

<!-- Add video link here -->

<video width="100%" controls>
  <source src="./Demo/DataLoader.mp4" type="video/mp4">
</video>


## ⚙️ How It Works

1. Upload a CSV file  
2. CSV is parsed into rows and columns  
3. Select a Salesforce Object  
4. Map CSV columns to Salesforce fields  
5. Click **Import Data**  
6. Records are inserted dynamically using Apex  

---

## 🧠 Key Concepts Used

- Dynamic Apex (`Schema.getGlobalDescribe()`)
- `ContentVersion` for file handling
- `List<Map<String, Object>>` for flexible data handling
- LWC → Apex communication
- SLDS for UI styling

---

## 🚧 Limitations

- Basic CSV parsing (does not support quoted commas yet)
- No field type validation (Date, Number, etc.)
- No row-level error display

---

## 🔮 Future Improvements

- ✅ CSV preview table
- ✅ Auto field mapping
- ✅ Data validation (required fields, types)
- ✅ Row-level error reporting
- ✅ Better CSV parsing

---

## 🛠️ Setup Instructions

1. Clone the repository:
   ```bash
   git clone https://github.com/mohdwajahat/Data-Loader.git