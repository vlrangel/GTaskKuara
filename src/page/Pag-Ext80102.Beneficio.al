pageextension 80102 Beneficio extends "Job Cost Factbox"
{
    layout
    {
        addafter("No.")
        {
            field("% facturado"; facturado)
            {
                Caption = '% Invoiced';
                ApplicationArea = All;
            }
            field("% beneficio prev."; beneficio)
            {
                Caption = '% Budget Profit';
                ApplicationArea = All;

            }
            field("% beneficio real"; beneficioreal)
            {
                Caption = '% Profit';
                ApplicationArea = All;

            }
            field("Coste vs Presupuesto"; costevspres)
            {
                Caption = 'Cost vs Budget';
                ApplicationArea = All;

            }

        }
    }
    var
        facturado: Decimal;
        beneficio: Decimal;
        beneficioreal: Decimal;
        costevspres: Decimal;
        JobCalcStatistics: Codeunit "Job Calculate Statistics";
        PlaceHolderLbl: Label 'Placeholder';
        CL: array[16] of Decimal;
        PL: array[16] of Decimal;

    trigger OnAfterGetCurrRecord()
    begin
        Clear(JobCalcStatistics);
        JobCalcStatistics.JobCalculateCommonFilters(Rec);
        JobCalcStatistics.CalculateAmounts;
        JobCalcStatistics.GetLCYCostAmounts(CL);
        JobCalcStatistics.GetLCYPriceAmounts(PL);
        //PL[12] Total Previsto venta
        //PL[15] Total Venta
        //CL[8] Total Coste
        //CL[4] Total Coste previsto
        if PL[12] <> 0 Then
            facturado := Round(PL[16] / PL[12] * 100, 0.01, '=');
        If PL[15] <> 0 then
            beneficioreal := Round((PL[16] - CL[8]) / PL[16] * 100, 0.01, '=');
        If PL[12] <> 0 then
            beneficio := Round((PL[12] - CL[4]) / PL[12] * 100, 0.01, '=');
        costevspres := CL[8] - cl[6];
    end;
}
