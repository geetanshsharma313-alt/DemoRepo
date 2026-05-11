import { api } from 'lwc';
import LightningModal from 'lightning/modal'
import { createRecord } from "lightning/uiRecordApi";
import CASE_COMMENT_OBJECT from "@salesforce/schema/CaseComment";
import BODY_FIELD from '@salesforce/schema/CaseComment.CommentBody';
import PUBLISHED_FIELD from '@salesforce/schema/CaseComment.IsPublished';
import PARENT_ID_FIELD from '@salesforce/schema/CaseComment.ParentId';
export default class ScCommentsModal extends LightningModal {

    @api content;
    showSpinner = false;
    commentBody;

    handleChange(event) {
        this.commentBody = event.target.value;
    }

    handleClick() {

        if (!this.commentBody) {
            return;
        }

        this.showSpinner = true;
        const fields = {};
        fields[BODY_FIELD.fieldApiName] = this.commentBody;
        fields[PUBLISHED_FIELD.fieldApiName] = true;
        fields[PARENT_ID_FIELD.fieldApiName] = this.content.Id;

        const recordInput = { apiName: CASE_COMMENT_OBJECT.objectApiName, fields };

        createRecord(recordInput)
            .then((caseComment) => {
                this.showSpinner = false;
                this.close('okay');
            })
            .catch((error) => {
                this.showSpinner = false;
            });

    }

}