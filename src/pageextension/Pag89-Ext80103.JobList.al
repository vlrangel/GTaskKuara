pageextension 80103 JobList extends "Job List" //89
{
    layout
    {
        addbefore(Control1907234507)
        {
            part(Estadisticas; "Job Cost Factbox")
            {
                Caption = 'Statistics';
                ApplicationArea = Jobs;
                SubPageLink = "No." = FIELD("No.");
                Visible = true;
            }
        }
    }
}
