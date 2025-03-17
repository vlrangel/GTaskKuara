pageextension 80109 "Configuración Contabilidad" extends "General Ledger Setup" //118
{
    layout
    {
        addlast(Application)
        {
            group(Tareas)
            {
                field("Url Tareas"; Rec."Url Tareas")
                {
                    ApplicationArea = All;
                }
                field("Usuario Tareas"; Rec."Usuario Tareas")
                {
                    ApplicationArea = All;
                }
                field("Password Tareas"; Rec."Password Tareas")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
    actions
    {
        addlast(Creation)
        {
            action("Recupera Token")
            {
                Image = UserCertificate;
                ApplicationArea = All;
                trigger OnAction()
                var
                    RestApi: Codeunit Restapi;
                    GenSetup: Record "General Ledger Setup";
                begin
                    GenSetup.Get();
                    RestApi.RecuperarToken(GenSetup."Url Tareas", GenSetup."Usuario Tareas", GenSetup."Password Tareas", GenSetup.Token);

                end;
            }
            action("Recupera Establecimiento")
            {
                Image = Company;
                ApplicationArea = All;
                trigger OnAction()
                var
                    RestApi: Codeunit Restapi;
                    GenSetup: Record "General Ledger Setup";
                    jSon: Text;
                begin
                    GenSetup.Get();
                    GenSetup.Establisment := RestApi.Establecimiento('/users');
                    GenSetup.Modify();


                end;
            }
        }

    }
}
