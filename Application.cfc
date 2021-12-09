component {

    this.name = "PDFArrange";
    this.sessionManagement = true;
    this.sessionTimeout = CreateTimeSpan(0, 0, 30, 0); //30 minutes

    public void function onSessionEnd(required struct sessionScope, struct applicationScope={}) { 

        local directory = GetDirectoryFromPath(GetCurrentTemplatePath()) & "workspaces\#sessionScope.workspace#\";
        if (directoryExists(directory)) {
            directoryDelete(directory, true);
            structDelete(sessionScope, "workspace");
        }
    } 

}