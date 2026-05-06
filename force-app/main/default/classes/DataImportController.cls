public with sharing class DataImportController {
    @AuraEnabled
    public static List<String> getCSVData(String docId){
        try {
            if(String.isBlank(docId)){
                throw new AuraHandledException('provide a valid document Id');
            }

            List<ContentVersion> file = [
                SELECT Id,Title,VersionData
                FROM ContentVersion 
                WHERE ContentDocumentId = : docId AND IsLatest = true
                WITH USER_MODE
                LIMIT 1
                ];

            if(file.isEmpty()){
                throw new AuraHandledException('No file found for the given document Id');
            }
            String fileData = file[0].VersionData.toString();
            List<String> formattedData = fileData.split('\n');

            return formattedData;
        } catch (Exception e) {
            throw new AuraHandledException('Error reading CSV: ' + e.getMessage());
        }
        
    }
    @AuraEnabled(cacheable=true)
    public static List<SObjectDescribe> getCreateableObjects(){
        List<SObjectDescribe> createableObjects = new List<SObjectDescribe>();
        for(Schema.SObjectType objectType : Schema.getGlobalDescribe().values()){
            Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            if(describeResult.isCreateable() && !describeResult.isCustomSetting() && !describeResult.getName().endsWith('Share')
                && !describeResult.getName().endsWith('History')){
                createableObjects.add(new SObjectDescribe(describeResult.getLabel(),describeResult.getName()));
            }
        }
        return createableObjects;
    }
    @AuraEnabled(cacheable=true)
    public static List<SObjectFieldDescribe> getFieldsForObject(String objectName){
        List<SObjectFieldDescribe> fieldsList = new List<SObjectFieldDescribe>();

        if (String.isBlank(objectName)) {
            throw new AuraHandledException('Provide a valid object name');
        }
        // get the objectType
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        // describe the object
        if(objectType == null){
            throw new AuraHandledException('Invalid object name: ' + objectName);
        }
        Schema.DescribeSObjectResult describeResult = objectType.getDescribe();
            // retreive every field of selected object
        for(Schema.SObjectField field : describeResult.fields.getMap().values()){
            // describe every field 
            Schema.DescribeFieldResult f = field.getDescribe();
            // check if it's createable
            if(f.isCreateable()){
                // add it to the list
                fieldsList.add(new SObjectFieldDescribe(f.getLabel(),f.getName()));
            }
        }
        // return the list.
        return fieldsList;
    }
    @AuraEnabled
    public static List<String> insertRecords(List<Map<String,Object>> records,String objName){
        try {
            if (String.isBlank(objName)) {
                throw new AuraHandledException('Provide a valid object name');
            }
            if (records == null || records.isEmpty()) {
                throw new AuraHandledException('No records to insert');
            }

            Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objName);
            if (objectType == null) {
                throw new AuraHandledException('Invalid object name: ' + objName);
            }

            Map<String,Schema.SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
            List<SObject> sRecords = new List<SObject>();

            for(Map<String,Object> record : records){
                SObject sObjectRecord = objectType.newSObject();
                for(String field : record.keySet()){
                    if(fieldMap.containsKey(field) && fieldMap.get(field).getDescribe().isCreateable()){
                        sObjectRecord.put(field, record.get(field));
                    }
                }
                sRecords.add(sObjectRecord);
            }
            return databaseInsert(sRecords);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public static List<String> databaseInsert(List<SObject> sRecords){
        try {
            Database.SaveResult[] results = Database.insert(sRecords,false);
            List<String> errors = new List<String>();

            for(Integer i = 0 ; i < results.size() ; i++){
                if(!results[i].isSuccess()){
                    for(Database.Error err : results[i].getErrors()){
                        errors.add('Row' + (i + 1) + ':' + err.getMessage());
                    }
                }
            }

            return errors;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    public class SObjectDescribe{
        @AuraEnabled public String label;
        @AuraEnabled public String name;

        public SObjectDescribe(String label,String name){
            this.label = label;
            this.name = name;
        }
    }
    public class SObjectFieldDescribe{
        @AuraEnabled public String label;
        @AuraEnabled public String name;

        public SObjectFieldDescribe(String label,String name){
            this.label = label;
            this.name = name;
        }
    }
}