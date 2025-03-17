tableextension 80405 SalRecSetup extends "Sales & Receivables Setup"
{
    fields
    {

        field(80124; "Producto Servicio"; Code[20])
        {
            TableRelation = "No. Series";
        }

    }

    var
        myInt: Integer;
}