public with sharing class SC_CaseTriggerHandler {
    
    private static final String SUPPORT_REC_TYPE_NAME        = 'Support';
    private static final String GET_CASE_DETAILS_PROMPT_TEMP = 'Get_Case_Details';
    
    public static void beforeInsert(List<Case> newCases){
        Id supportRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(SUPPORT_REC_TYPE_NAME).getRecordTypeId();
        for(Case cs : newCases) {
            if(cs.Origin == 'Email' && cs.RecordTypeId == supportRecTypeId){
                //Prompt template
                ConnectApi.WrappedValue inputValueMapSubject = new ConnectApi.WrappedValue();
                inputValueMapSubject.value = cs.Subject;
                ConnectApi.WrappedValue inputValueMapBody = new ConnectApi.WrappedValue();
                inputValueMapBody.value = cs.Description;
                
                Map<String, ConnectApi.WrappedValue> inputParams = new Map<String, ConnectApi.WrappedValue>();        
                inputParams.put('Input:EmailSubject', inputValueMapSubject);
                inputParams.put('Input:EmailBody', inputValueMapBody); 
                
                String result = invokePrompt(GET_CASE_DETAILS_PROMPT_TEMP, inputParams);
                Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
                
                if(resultMap.containsKey('priority')){
                    cs.Priority = (String)resultMap.get('priority');
                }
                
            }
        }
        
    }
    
    public static String invokePrompt(String promptTemplateDeveloperName, Map<String, ConnectApi.WrappedValue> inputParams){
        
        ConnectApi.EinsteinPromptTemplateGenerationsInput promptGenerationsInput = new ConnectApi.EinsteinPromptTemplateGenerationsInput();
        
        promptGenerationsInput.inputParams = inputParams;
        promptGenerationsInput.additionalConfig = new ConnectApi.EinsteinLlmAdditionalConfigInput();
        promptGenerationsInput.additionalConfig.numGenerations = 1;
        promptGenerationsInput.additionalConfig.enablePiiMasking = true;
        promptGenerationsInput.additionalConfig.applicationName = 'PromptTemplateGenerationsInvocable';
        
        promptGenerationsInput.isPreview = false;
        
        ConnectApi.EinsteinPromptTemplateGenerationsRepresentation generationsOutput = ConnectApi.EinsteinLLM.generateMessagesForPromptTemplate(promptTemplateDeveloperName, promptGenerationsInput);
        
        ConnectApi.EinsteinLLMGenerationItemOutput response = generationsOutput.generations[0];    
        return response.text;
    }

}