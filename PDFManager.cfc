<cfcomponent>

    <cfscript>

        // Converts the base64 string made by generateSecretKey() into hex 
        // so we don't have to deal with slashes in our folder names
        private String function base64ToHex(required String base64String) {

            local binaryValue = BinaryDecode(base64String, "Base64");
            local hexvalue = BinaryEncode(binaryValue, "Hex");

            return hexvalue;

        }

        // Returns a unique folder name for the user to upload to
        private String function assignWorkspace() {

            local workspace = base64ToHex(generateSecretKey("AES", 128));
            local directory = GetDirectoryFromPath(GetCurrentTemplatePath()) & "workspaces\#workspace#\";

            // In the unlikely event the workspace already exists, try again
            if (directoryExists(directory)) {
                return assignWorkspace();
            }

            return workspace;
        }

    </cfscript>

    <!--- Generates a thumbnail image for each page of the doc and returns HTML to render the workspace --->
    <cffunction  name="splitPDF" access="remote" returnformat="plain">

        <cfset Session.workspace = assignWorkspace()>
    
        <cfset uploadPath = #GetDirectoryFromPath(GetCurrentTemplatePath())# & "workspaces\#Session.workspace#\">
        <cfset thumbnailPath = uploadPath & "thumbnails\">

        <cfdirectory action="create" directory="#thumbnailPath#">
    
        <cffile  action="uploadAll" allowedExtensions=".pdf" destination="#uploadPath#">

        <cfpdf  action="merge" directory="#uploadPath#" name="doc"/>
        <cfpdf  action="thumbnail" source="doc" destination="#thumbnailPath#" overwrite="true"/>
        <cfpdf  action="getinfo" name="docData" source="doc"/>

        <cfpdf action="write" source="doc" overwrite="true" destination="#uploadPath#document.pdf">

        <cfsavecontent  variable="output">

            <cfloop index="i" from="1" to="#docData.TotalPages#">

                <cfset thumbnail = "workspaces/#Session.workspace#/thumbnails/thumbnail_page_" & i & ".jpg">

                <cfoutput>

                    <div class="col page" id="#i#" draggable="true">
                        <div class="card shadow-sm">
                            <img src="#thumbnail#" class="card-img-top" alt="..." draggable="false">
        
                            <div class="card-body">
                            <p class="card-text">Page #i#</p>
                            <div class="d-flex justify-content-between align-items-center">
                                <div class="btn-group">
                                    <button type="button" class="btn btn-sm btn-outline-secondary deletepage">X</button>
                                </div>
                            </div>
                            </div>
                        </div>
                    </div>

                </cfoutput>
                
            </cfloop>

        </cfsavecontent>

        <cfreturn output>
    
    </cffunction>

    <!--- Merges the remaining workspace pages back into a single document in the order arranged --->
    <cffunction  name="mergePDF" access="remote" returnformat="plain">
        
        <cfset docPath = #GetDirectoryFromPath(GetCurrentTemplatePath())# & "workspaces\#Session.workspace#\document.pdf">

        <cfpdf  action="read" name="doc" source="#docPath#"/>

        <cfpdf  action="merge" name="output">
            <cfloop list="#Form.pageList#" item="page">
                <cfpdfparam  source="doc" pages="#page#"/>
            </cfloop>
        </cfpdf>

        <cfpdf  action="write" source="output" overwrite="true" destination="#docPath#">

        <cfreturn Session.workspace>

    </cffunction>

    <!--- Reset the session --->
    <cffunction  name="clearWorkspace" access="remote">

        <cfset directory = #GetDirectoryFromPath(GetCurrentTemplatePath())# & "workspaces\#Session.workspace#\">
        <cfset DirectoryDelete(directory, true)>
        <cfset structDelete(Session, "workspace")>

    </cffunction>

</cfcomponent>