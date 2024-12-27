/// <summary>
/// TableExtension GeneralSetup (ID 80102) extends Record General Ledger Setup.
/// </summary>
tableextension 80102 GeneralSetup extends "General Ledger Setup"
{
    fields
    {
        field(80100; "Url Tareas"; Text[1024])
        {
            Caption = 'Url Tareas';
            DataClassification = ToBeClassified;
        }
        field(80101; "Usuario Tareas"; Text[30])
        {
            Caption = 'Usuario Tareas';
            DataClassification = ToBeClassified;
        }
        field(80102; "Password Tareas"; Text[30])
        {
            Caption = 'Password Tareas';
            DataClassification = ToBeClassified;
        }
        field(80103; Token; Text[1024])
        {

        }
        field(80104; "Fecha Token"; DateTime)
        {

        }
        field(80105; Establisment; Text[250])
        {

        }
    }
}
