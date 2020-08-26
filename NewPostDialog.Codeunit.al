codeunit 83001 NewPostDialog
{
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post (Yes/No)", 'OnBeforeConfirmSalesPost', '', false, false)]
    local procedure NewConfirm(var SalesHeader: Record "Sales Header"; var HideDialog: Boolean)
    begin
        HideDialog := true;
        NewConfirmPost(SalesHeader);
    end;

    local procedure NewConfirmPost(var SalesHeader: Record "Sales Header"): Boolean
    var
        Selection: Integer;
        ConfirmManagement: Codeunit "Confirm Management";
        ShipInvoiceQst: Label 'Ship &and Invoice New';
        PostConfirmQst: Label 'Do you want to post the %1?', Comment = '%1 = Document Type';
        ReceiveInvoiceQst: Label '&Receive,&Invoice,Receive &and Invoice';
        NothingToPostErr: Label 'There is nothing to post.';
    begin

        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order:
                begin
                    Selection := StrMenu(ShipInvoiceQst, 1);
                    SalesHeader.Ship := Selection in [1, 1];
                    SalesHeader.Invoice := Selection in [1, 1];
                    if Selection = 0 then
                        exit(false);
                end;
            SalesHeader."Document Type"::"Return Order":
                begin
                    Selection := StrMenu(ReceiveInvoiceQst, 1);
                    if Selection = 0 then
                        exit(false);
                    SalesHeader.Receive := Selection in [1, 3];
                    SalesHeader.Invoice := Selection in [2, 3];
                end
            else
                if not ConfirmManagement.GetResponseOrDefault(
                     StrSubstNo(PostConfirmQst, LowerCase(Format(SalesHeader."Document Type"))), true)
                then
                    exit(false);
        end;
        SalesHeader."Print Posted Documents" := false;
        exit(true);
    end;
}