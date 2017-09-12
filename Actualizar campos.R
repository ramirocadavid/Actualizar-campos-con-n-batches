# Este script actualiza todos los registros de un objeto de Salesforce.
# Antes de ejecutarlo, es necesario modificar los valores de la sección
# 'Parámetros iniciales' con el fin de indicar el objeto que se quiere
# actualizar, el campo que se actualizará y las credenciales de la cuenta
# de Salesforce en la que se iniciará sesión.
# 
# No es necesario hacer ninguna modificación en la sección 'Actualización'


# Parametros iniciales ----------------------------------------------------

# Parametros iniciales
objeto <- "FMP_Diagnostic_TargetDefinition__c"
campos <- c("Id", "Farm_Baseline__c")
tamano_batch <- 40

# Login a Salesforce
library(RForcecom)
username <- "admin@andes.org"
password <- "admgf2017#XQWRiDpPU6NzJC9Cmm185FF2"
instanceURL <- "https://taroworks-8629.cloudforce.com/"
apiVersion <- "36.0"
session <- rforcecom.login(username, password, instanceURL, apiVersion)



# Actualización -----------------------------------------------------------


# Descargar archivos
actualizar <- rforcecom.retrieve(session, objeto, campos)
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
                                          batchSize = tamano_batch)

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
