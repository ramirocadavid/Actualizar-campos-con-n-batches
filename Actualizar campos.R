# Directorio de trabajo
setwd("C:/Users/Ramiro/Desktop")

# Login a Salesforce
library(RForcecom)
username <- "admin@andes.org"
password <- "admgf2017#XQWRiDpPU6NzJC9Cmm185FF2"
instanceURL <- "https://taroworks-8629.cloudforce.com/"
apiVersion <- "36.0"
session <- rforcecom.login(username, password, instanceURL, apiVersion)

# Descargar archivos
actualizar <- rforcecom.retrieve(session, "FMP_Diagnostic_TargetDefinition__c",
                                 c("Id", "Farm_Baseline__c"))
# # Datos de Prueba
# saveRDS(actualizar, "actualizar.rds")
# actualizar <- readRDS("actualizar.rds")

# Subir datos
job_info <- rforcecom.createBulkJob(session, 
                                    operation='update', 
                                    object='FMP_Diagnostic_TargetDefinition__c')

batches_info <- rforcecom.createBulkBatch(session, 
                                          jobId=job_info$id, 
                                          actualizar, 
                                          multiBatch = TRUE, 
                                          batchSize = 40)

# check on status of each batch
batches_status <- lapply(batches_info, 
                         FUN=function(x){
                               rforcecom.checkBatchStatus(session, 
                                                          jobId=x$jobId, 
                                                          batchId=x$id)
                         })
# get details on each batch
batches_detail <- lapply(batches_info, 
                         FUN=function(x){
                               rforcecom.getBatchDetails(session, 
                                                         jobId=x$jobId, 
                                                         batchId=x$id)
                         })

# close the job
close_job_info <- rforcecom.closeBulkJob(session, jobId=job_info$id)
# Close the session
rforcecom.logout(session)
