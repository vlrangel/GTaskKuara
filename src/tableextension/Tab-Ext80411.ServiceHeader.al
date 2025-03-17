// table 80108 "Link"
// {
//     Caption = 'Link ';
//     DataClassification = ToBeClassified;

//     fields
//     {
//         field(1; Id; RecordId)
//         {
//             Caption = 'Id';
//             DataClassification = ToBeClassified;
//         }
//         field(2; Link_Id; Text[250])
//         {
//             Caption = 'Link_Id';
//             DataClassification = ToBeClassified;
//         }
//         field(3; Tipo; Integer)
//         {
//             Caption = 'Tipo';
//             DataClassification = ToBeClassified;
//         }
//     }
//     keys
//     {
//         key(PK; Id, Tipo)
//         {
//             Clustered = true;
//         }
//     }

// }
// table 80109 "Tipo de Incidencia"
// {
//     fields
//     {
//         field(1; "Código"; Code[20])
//         {

//         }
//         field(2; "Descripción"; Text[250])
//         { }
//     }
//     keys
//     {
//         key(Pk; "Código")
//         {
//             Clustered = true;
//         }
//     }
// }
tableextension 80411 ServiceHeader extends "Service Header"
{
    fields
    {
        field(80100; "Preferred Resource"; Code[20])
        {
            TableRelation = Resource;
            Caption = 'Recurso preferido';
        }
        field(80200; "Work Description"; BLOB)
        {
            Caption = 'Descripción Trabajo';
        }
        field(80201; Id_Tarea; Text[250])
        {
            Caption = 'Id Tarea';
        }

    }
    procedure SetWorkDescription(NewWorkDescription: Text)
    var
        OutStream: OutStream;
    begin
        Clear("Work Description");
        "Work Description".CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WriteText(NewWorkDescription);
        Modify;
    end;

    procedure GetWorkDescription(): Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStream: InStream;
    begin
        CalcFields("Work Description");
        "Work Description".CreateInStream(InStream, TEXTENCODING::UTF8);
        exit(TypeHelper.ReadAsTextWithSeparator(InStream, TypeHelper.LFSeparator));
    end;

}
tableextension 80412 ServiceLine extends "Service Line"
{
    fields
    {
        modify("Service Item No.")
        {
            trigger OnAfterValidate()
            var
                ServiceHeader: Record "Service Header";
                ServiceItem: Record "Service Item";
            begin
                if ServiceHeader.Get(Rec."Document Type", Rec."Document No.") then begin
                    If ServiceHeader."Document Type" = ServiceHeader."Document Type"::Order then
                        If ServiceItem.Get(Rec."Service Item No.") Then begin
                            ServiceHeader."Preferred Resource" := ServiceItem."Preferred Resource";
                            ServiceHeader.Modify();
                        end;
                end;
            end;
        }
    }
}