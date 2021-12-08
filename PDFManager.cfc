<cfcomponent>

    <!--- Generates a thumbnail image for each page of the doc and returns HTML to render the workspace --->
    <cffunction  name="splitPDF" access="remote" returnformat="plain">
    
        <cfset uploadPath = #GetDirectoryFromPath(GetCurrentTemplatePath())# & "workspace\">
        <cfset thumbnailPath = uploadPath & "thumbnails\">

        <cfif !directoryExists(uploadPath)>
            <cfdirectory action="create" directory="#uploadPath#">
        </cfif>

        <cfif !directoryExists(thumbnailPath)>
            <cfdirectory action="create" directory="#thumbnailPath#">
        </cfif>
    
        <cffile  action="uploadAll" allowedExtensions=".pdf" destination="#uploadPath#">

        <cfpdf  action="merge" directory="#uploadPath#" name="doc"/>
        <cfpdf  action="thumbnail" source="doc" destination="#thumbnailPath#" overwrite="true"/>
        <cfpdf  action="getinfo" name="docData" source="doc"/>

        <cfpdf action="write" source="doc" overwrite="true" destination="#uploadPath#document.pdf">

        <cfsavecontent  variable="output">

            <cfloop index="i" from="1" to="#docData.TotalPages#">
                <cfset thumbnail = "workspace/thumbnails/thumbnail_page_" & i & ".jpg">
                <cfoutput>

                    <div class="card col" id="#i#" draggable="true">
                        <img src="#thumbnail#" class="card-img-top" alt="..." draggable="false">
                        <div class="card-body">
                            <h6 class="card-title">Page #i#</h6>
                            <button type="button" class="btn btn-danger deletepage">X</button>
                        </div>
                    </div>

                </cfoutput>
            </cfloop>

        </cfsavecontent>

        <cfreturn output>
    
    </cffunction>

    <!--- Merges the remaining workspace pages back into a single document in the order arranged --->
    <cffunction  name="mergePDF" access="remote">
        
        <cfset docPath = #GetDirectoryFromPath(GetCurrentTemplatePath())# & "workspace\document.pdf">

        <cfpdf  action="read" name="doc" source="#docPath#"/>

        <cfpdf  action="merge" name="output">
            <cfloop list="#Form.pageList#" item="page">
                <cfpdfparam  source="doc" pages="#page#"/>
            </cfloop>
        </cfpdf>

        <cfpdf  action="write" source="output" overwrite="true" destination="#docPath#">

    </cffunction>

    <cffunction  name="clearWorkspace" access="remote">

        <cfset directory = #GetDirectoryFromPath(GetCurrentTemplatePath())# & "workspace\">
        <cfset DirectoryDelete(directory, true)>

    </cffunction>

</cfcomponent>