pageextension 80101 Proyecto extends "Job Card" //88
{
    actions
    {
        addafter("&Job")
        {
            action("Crear Tarea")
            {
                Caption = 'Create task';
                Image = Task;
                ApplicationArea = All;
                Promoted = true;
                trigger OnAction()
                var
                    Tareas: Record "User Task";
                    Gtask: Codeunit GTask;
                    Id: Integer;

                begin
                    Tareas.Init();
                    Tareas.Title := Rec.Description;
                    Tareas."Created DateTime" := CurrentDateTime;
                    Tareas."Object Type" := Tareas."Object Type"::Page;
                    Tareas."Object ID" := 80111;
                    Tareas.Insert(true);
                    Id := Tareas.ID;
                    Commit();
                    Page.RunModal(Page::"User Task Card", Tareas);
                    Commit();
                    Tareas.Get(Id);
                    Gtask.CrearTareaJob(Rec, Tareas);

                end;
            }
        }
    }
}
