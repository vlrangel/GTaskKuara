page 80104 "Lineas parte de trabajo"
{

    Caption = 'Lineas parte de trabajo';
    PageType = ListPart;
    SourceTable = "Time Sheet Line";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(Tipo; Rec.Tipo)
                {
                    ToolTip = 'Specifies the value of the Tipo field.';
                    ApplicationArea = All;
                }
                field(No; Rec.No)
                {
                    ToolTip = 'Specifies the value of the No field.';
                    ApplicationArea = All;
                }
                field(Descripcion; Rec.Descripcion)
                {
                    ToolTip = 'Specifies the value of the Descripcion field.';
                    ApplicationArea = All;
                }
                field(Unidad; Rec.Unidad)
                {
                    ToolTip = 'Specifies the value of the Unidad field.';
                    ApplicationArea = All;
                }
                field(Cantidad; Rec.Cantidad)
                {
                    ToolTip = 'Specifies the value of the Cantidad field.';
                    ApplicationArea = All;
                }
            }
        }
    }

}
