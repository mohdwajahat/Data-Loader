// Use .apex files to store anonymous Apex.
// You can execute anonymous Apex in VS Code by selecting the
//     apex text and running the command:
//     SFDX: Execute Anonymous Apex with Currently Selected Text
// You can also execute the entire file by running the command:
//     SFDX: Execute Anonymous Apex with Editor Contents

Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe();
Schema.SObjectType accountType = gd.get('Account');
Schema.DescribeSObjectResult desc = accountType.getDescribe();

System.debug(desc.getName()); // Account
System.debug(desc.isCreateable());
System.debug(gd);