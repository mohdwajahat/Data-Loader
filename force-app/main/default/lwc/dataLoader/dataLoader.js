import { LightningElement } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getCSVData from '@salesforce/apex/DataImportController.getCSVData';
import getCreateableObjects from '@salesforce/apex/DataImportController.getCreateableObjects';
import getFieldsForObject from '@salesforce/apex/DataImportController.getFieldsForObject';
import insertRecords from '@salesforce/apex/DataImportController.insertRecords';

export default class DataLoader extends LightningElement {
    salesforceObjects = [];
    columnSelection = []; // array of objects [{label : 'New', value : 'new'}]
    fields = [];
    fileData = [];
    selectedObjectApiName = '';
    fieldMapping = {};

    get acceptedFormats() {
        return [".csv"];
    }

    connectedCallback() {
        // get Objects list
        this.getObjects();
    }

    handleUploadFinished(event) {
        const file = event.detail.files[0];
        const documentId = file.documentId;
        // reads the csv file
        this.readFile(documentId);
    }
    async readFile(documentId) {
        try {
            const csvData = await getCSVData({ docId: documentId });

            if (!csvData || csvData.length == 0) {
                throw new Error('Empty csv');
                return;
            }
            // format Headers
            this.getCSVHeaders(csvData[0]);
            // get the values of the field
            this.getFileValues(csvData);
        } catch (error) {
            console.error('File read error:', error);
        }
    }
    getFileValues(csvData) {
        const headers = this.columnSelection.map(header => header.label);
        const fileValues = [];
        for (let i = 1; i < csvData.length; i++) {
            let row = {};
            let rowValues = csvData[i].replaceAll('\r', '').split(',');

            for (let k = 0; k < headers.length; k++) {
                row[headers[k]] = rowValues[k];
            }
            fileValues.push(row);
        }
        this.fileData = fileValues;
    }

    getCSVHeaders(headersRow) {
        this.columnSelection = headersRow.replaceAll('\r', '').split(',').map((header) => {
            return {
                'label': header,
                'value': header,
            }
        })
    }

    async getObjects() {
        const response = await getCreateableObjects();
        this.salesforceObjects = response.map((res) => {
            return {
                label: res.label.trim(),
                value: res.name
            }
        })

        // sort objects in alphabatical order of their label.
        this.salesforceObjects.sort((a, b) => a.label.localeCompare(b.label));
    }

    async getFieldsForSelectedObject() {
        const response = await getFieldsForObject({ objectName: this.selectedObjectApiName });
        this.fields = response;
    }

    handleSelectedObject(event) {
        this.selectedObjectApiName = event.detail.value;
        this.getFieldsForSelectedObject();
    }
    handleColumnSelection(event) {
        const csvColumn = event.detail.value;
        const objColumn = event?.target?.dataset?.name;
        if (csvColumn && objColumn) {
            this.fieldMapping[csvColumn] = objColumn;
        }
    }
    handleImportClick() {
        if (!this.selectedObjectApiName) {
            console.error('select an object first');
            return;
        }

        if (!this.fileData.length) {
            console.error('No data to import');
            return;
        }

        if (Object.keys(this.fieldMapping).length == 0) {
            console.error('No field mapping defined');
            return;
        }
        const recordList = [];
        for (let i = 0; i < this.fileData.length; i++) {
            let record = {};
            // iterating each record
            let csvColumns = Object.keys(this.fileData[i]);

            for (let j = 0; j < csvColumns.length; j++) {
                let csvColumn = csvColumns[j];
                let objColumn = this.fieldMapping[csvColumn];

                if (objColumn) {
                    record[objColumn] = this.fileData[i][csvColumn];
                }
            }
            if (Object.keys(record).length > 0) {
                recordList.push(record);
            }
        }
        // call the apex method to inser the records
        this.insertRecordsOfCSV(recordList);
    }
    async insertRecordsOfCSV(recordList) {
        try {
            await insertRecords({
                records: recordList,
                objName: this.selectedObjectApiName
            });
            console.log('Records inserted successfully');
            this.dispatchEvent(new ShowToastEvent({
                title: 'Success',
                message: 'Records inserted successfully',
                variant: 'success'
            }))
        } catch (error) {
            console.error('Insert failed:', error);
        }
    }
}