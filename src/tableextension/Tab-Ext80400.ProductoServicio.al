tableextension 80400 "Producto Servicio" extends Resource
{
    Caption = 'Producto Servicio';
    DataCaptionFields = "No.", Name;

    fields
    {
        modify("No.")
        {
            Caption = 'No.';


        }

        field(80002; "Serial No."; Code[50])
        {
            Caption = 'Serial No.';

            trigger OnValidate()
            begin
                if "Serial No." <> xRec."Serial No." then
                    MessageIfServItemLinesExist(FieldCaption("Serial No."));

                if "Serial No." <> '' then begin
                    ServItem.Reset();
                    ServItem.SetCurrentKey("Item No.", "Serial No.");
                    ServItem.SetRange("Item No.", "Item No.");
                    ServItem.SetRange("Serial No.", "Serial No.");
                    ServItem.SetFilter("No.", '<>%1', "No.");
                    if ServItem.FindFirst then begin
                        if "Item No." <> '' then
                            Error(
                              Text003,
                              FieldCaption("Serial No."), "Serial No.", TableCaption, ServItem."No.");
                        Message(
                          Text003,
                          FieldCaption("Serial No."), "Serial No.", TableCaption, ServItem."No.")
                    end;
                end;

                // if "Serial No." <> xRec."Serial No." then
                //     ServLogMgt.ServItemSerialNoChange(Rec, xRec);
            end;
        }
        // field(8003; "Service Item Group Code"; Code[10])
        // {
        //     Caption = 'Service Item Group Code';
        //     TableRelation = "Service Item Group";

        //     trigger OnValidate()
        //     begin
        //         if xRec."Service Item Group Code" = "Service Item Group Code" then begin
        //             if not CancelResSkillAssignment then
        //                 ResSkillMgt.RevalidateResSkillRelation(
        //                   ResSkill.Type::"Service Item",
        //                   "No.",
        //                   ResSkill.Type::"Service Item Group",
        //                   "Service Item Group Code")
        //         end else begin
        //             if not CancelResSkillAssignment then begin
        //                 if CancelResSkillChanges then
        //                     ResSkillMgt.SkipValidationDialogs;

        //                 if not ResSkillMgt.ChangeResSkillRelationWithGroup(
        //                      ResSkill.Type::"Service Item",
        //                      "No.",
        //                      ResSkill.Type::"Service Item Group",
        //                      "Service Item Group Code",
        //                      xRec."Service Item Group Code")
        //                 then
        //                     Error('');

        //                 if CancelResSkillChanges then begin
        //                     ResSkillMgt.DropGlobals;
        //                     CancelResSkillChanges := false;
        //                 end else
        //                     CancelResSkillChanges := true;
        //             end;

        //             if "Service Item Group Code" <> '' then begin
        //                 ServItemGr.Get("Service Item Group Code");
        //                 "Default Contract Discount %" := ServItemGr."Default Contract Discount %";
        //                 if "Service Price Group Code" = '' then
        //                     "Service Price Group Code" := ServItemGr."Default Serv. Price Group Code";
        //                 if (xRec."Service Item Group Code" <> "Service Item Group Code") and
        //                    (ServItemGr."Default Response Time (Hours)" <> 0)
        //                 then
        //                     "Response Time (Hours)" := ServItemGr."Default Response Time (Hours)";
        //             end;
        //         end;
        //         Modify;
        //     end;
        // }
        // modify(Name)
        // {
        //     Caption = 'Description';

        //     trigger OnAfterValidate()
        //     begin
        //         if ("Search Description" = UpperCase(xRec.Name)) or ("Search Description" = '') then
        //             "Search Description" := Name;
        //     end;
        // }
        // field(80005; "Description 2"; Text[50])
        // {
        //     Caption = 'Description 2';
        // }
        field(80006; Status; Enum "Service Item Status")
        {
            Caption = 'Status';

            trigger OnValidate()
            begin
                if (Status <> xRec.Status) And (Type = Type::Machine) then begin
                    if (Status = Status::Installed) and ("Installation Date" = 0D) then
                        "Installation Date" := WorkDate;
                    //     ServLogMgt.ServItemStatusChange(Rec, xRec);
                end;
            end;
        }
        field(80007; Priority; Option)
        {
            Caption = 'Priority';
            OptionCaption = 'Low,Medium,High';
            OptionMembers = Low,Medium,High;
        }
        field(80008; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            TableRelation = Customer;
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                ConfirmManagement: Codeunit "Confirm Management";
                Customer: Record Customer;
            begin
                if "Customer No." <> xRec."Customer No." then begin
                    // if CheckifActiveServContLineExist then
                    //     Error(Text004, FieldCaption("Customer No."), "Customer No.", TableCaption, "No.");
                    ServItemLinesExistErr(FieldCaption("Customer No."));
                    if ServLedgEntryExist then
                        if not ConfirmManagement.GetResponseOrDefault(
                             StrSubstNo(Text017, TableCaption, FieldCaption("Customer No.")), true)
                        then begin
                            "Customer No." := xRec."Customer No.";
                            exit;
                        end;
                    "Ship-to Code" := '';
                    if ("Customer No." <> '') and
                       (xRec."Customer No." = '')
                    then
                        Status := Status::Installed;
                    // Rec.CalcFields(Name, "Name 2", Address, "Address 2", "Post Code",
                    //   City, Contact, "Phone No.", County, "Country/Region Code");
                    //  ServLogMgt.ServItemCustChange(Rec, xRec);
                    if Customer.Get("Customer No.") Then begin
                        "Nombre Cilente" := Customer.Name;
                        Address := Customer.Address;
                        "Address 2" := Customer."Address 2";
                        "Post Code" := Customer."Post Code";
                        City := Customer.City;
                        Contact := Customer.Contact;
                        "Phone No." := Customer."Phone No.";
                        County := Customer.County;
                        "Country/Region Code" := Customer."Country/Region Code";
                    end;
                    //  ServLogMgt.ServItemShipToCodeChange(Rec, xRec);
                end;
            end;
        }
        field(80005; "Nombre Cilente"; Text[80])
        {

        }
        field(80009; "Ship-to Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = field("Customer No."));

            trigger OnValidate()
            var
                ConfirmManagement: Codeunit "Confirm Management";
            begin
                if "Ship-to Code" <> xRec."Ship-to Code" then begin
                    // if CheckifActiveServContLineExist then
                    //     Error(
                    //       Text004,
                    //       FieldCaption("Ship-to Code"), "Ship-to Code", TableCaption, "No.");
                    ServItemLinesExistErr(FieldCaption("Ship-to Code"));
                    if ServLedgEntryExist then
                        if not ConfirmManagement.GetResponseOrDefault(
                             StrSubstNo(Text017, TableCaption, FieldCaption("Customer No.")), true)
                        then begin
                            "Ship-to Code" := xRec."Ship-to Code";
                            exit;
                        end;
                    //   ServLogMgt.ServItemShipToCodeChange(Rec, xRec);
                end;
            end;
        }
        field(80010; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            var
                ConfirmManagement: Codeunit "Confirm Management";
            begin
                if "Item No." <> xRec."Item No." then begin
                    if "Item No." <> '' then begin
                        CalcFields("Service Item Components");
                        if "Service Item Components" then
                            if not ConfirmManagement.GetResponseOrDefault(
                                 StrSubstNo(
                                   ChangeItemQst, FieldCaption("Item No."),
                                   FieldCaption("Service Item Components")), true)
                            then begin
                                "Item No." := xRec."Item No.";
                                exit;
                            end;
                    end;
                    if not CancelResSkillAssignment then begin
                        if CancelResSkillChanges then
                            ResSkillMgt.SkipValidationDialogs;
                        if not ResSkillMgt.ChangeResSkillRelationWithItem(
                             ResSkill.Type::"Service Item",
                             "No.",
                             ResSkill.Type::Item,
                             "Item No.",
                             xRec."Item No.",
                             '')
                        then
                            Error('');
                        if CancelResSkillChanges then begin
                            ResSkillMgt.DropGlobals;
                            CancelResSkillChanges := false;
                        end else
                            CancelResSkillChanges := true;
                    end;
                    if "Item No." <> '' then begin
                        Item.Get("Item No.");
                        // Validate("Service Item Group Code", Item."Service Item Group");
                        Validate("Serial No.");
                        Validate("Sales Unit Cost", Item."Unit Cost");
                        Validate("Sales Unit Price", Item."Unit Price");
                        "Variant Code" := '';
                        "Unit of Measure Code" := Item."Base Unit of Measure";
                        if Name = '' then
                            Validate(Name, Item.Description);
                        // OnAfterAssignItemValues(Rec, xRec, Item, CurrFieldNo);
                        if "Service Item Components" then begin
                            DeleteServItemComponents;
                            CalcFields("Service Item Components");
                        end;
                    end else begin
                        "Serial No." := '';
                        Validate("Sales Unit Price", 0);
                        Validate("Sales Unit Cost", 0);
                        "Variant Code" := '';
                        //"Service Item Group Code" := '';
                        "Unit of Measure Code" := '';
                    end;
                    MessageIfServItemLinesExist(FieldCaption("Item No."));
                end else
                    if not CancelResSkillAssignment then
                        ResSkillMgt.RevalidateResSkillRelation(
                          ResSkill.Type::"Service Item",
                          "No.",
                          ResSkill.Type::Item,
                          "Item No.");

                // ServLogMgt.ServItemItemNoChange(Rec, xRec);
                Modify;
            end;
        }
        field(80011; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            TableRelation = IF ("Item No." = FILTER(<> '')) "Item Unit of Measure".Code WHERE("Item No." = field("Item No."))
            ELSE
            "Unit of Measure";
        }
        field(80012; "Location of Service Item"; Text[30])
        {
            Caption = 'Location of Service Item';
        }
        field(80013; "Sales Unit Price"; Decimal)
        {
            AutoFormatType = 2;
            BlankZero = true;
            Caption = 'Sales Unit Price';

            trigger OnValidate()
            begin
                ServMgtSetup.Get();
                Currency.InitRoundingPrecision;
                // if (ServMgtSetup."Contract Value Calc. Method" =
                //     ServMgtSetup."Contract Value Calc. Method"::"Based on Unit Price") and
                //    ("Sales Unit Price" <> xRec."Sales Unit Price")
                // then
                //     "Default Contract Value" :=
                //       Round("Sales Unit Price" * ServMgtSetup."Contract Value %" / 100,
                //         Currency."Unit-Amount Rounding Precision");
            end;
        }
        field(80014; "Sales Unit Cost"; Decimal)
        {
            AutoFormatType = 2;
            BlankZero = true;
            Caption = 'Sales Unit Cost';

            trigger OnValidate()
            begin
                ServMgtSetup.Get();
                Currency.InitRoundingPrecision;
                // "Default Contract Cost" :=
                //   Round("Sales Unit Cost" * ServMgtSetup."Contract Value %" / 100,
                //     Currency."Unit-Amount Rounding Precision");
                // if (ServMgtSetup."Contract Value Calc. Method" =
                //     ServMgtSetup."Contract Value Calc. Method"::"Based on Unit Cost") and
                //    ("Sales Unit Cost" <> xRec."Sales Unit Cost")
                // then
                //     "Default Contract Value" := "Default Contract Cost";
            end;
        }
        field(80015; "Warranty Starting Date (Labor)"; Date)
        {
            Caption = 'Warranty Starting Date (Labor)';

            trigger OnValidate()
            begin
                if "Warranty Starting Date (Labor)" <> xRec."Warranty Starting Date (Labor)" then
                    MessageIfServItemLinesExist(FieldCaption("Warranty Starting Date (Labor)"));

                ServMgtSetup.Get();
                // ServMgtSetup.Testfield("Default Warranty Duration");
                // if "Warranty Starting Date (Labor)" <> xRec."Warranty Starting Date (Labor)" then
                //     if "Warranty Starting Date (Labor)" <> 0D then
                //         Validate("Warranty Ending Date (Labor)", CalcDate(ServMgtSetup."Default Warranty Duration", "Warranty Starting Date (Labor)"))
                //     else
                //         "Warranty Ending Date (Labor)" := 0D;

                // if "Warranty Starting Date (Labor)" <> 0D then
                //     if "Warranty Starting Date (Parts)" = 0D then
                //         Validate("Warranty Starting Date (Parts)", "Warranty Starting Date (Labor)");
            end;
        }
        field(80016; "Warranty Ending Date (Labor)"; Date)
        {
            Caption = 'Warranty Ending Date (Labor)';

            trigger OnValidate()
            begin
                if "Warranty Ending Date (Labor)" <> xRec."Warranty Ending Date (Labor)" then
                    MessageIfServItemLinesExist(FieldCaption("Warranty Ending Date (Labor)"));

                if "Warranty Ending Date (Labor)" < "Warranty Starting Date (Labor)" then
                    Error(
                      Text007,
                      FieldCaption("Warranty Starting Date (Labor)"), FieldCaption("Warranty Ending Date (Labor)"));

                ServMgtSetup.Get();
                // if "Warranty % (Labor)" = 0 then
                //     "Warranty % (Labor)" := ServMgtSetup."Warranty Disc. % (Labor)";
            end;
        }
        field(80017; "Warranty Starting Date (Parts)"; Date)
        {
            Caption = 'Warranty Starting Date (Parts)';

            trigger OnValidate()
            var
                ItemTrackingCode: Record "Item Tracking Code";
            begin
                if "Warranty Starting Date (Parts)" <> xRec."Warranty Starting Date (Parts)" then
                    MessageIfServItemLinesExist(FieldCaption("Warranty Starting Date (Parts)"));

                if "Warranty Starting Date (Parts)" <> xRec."Warranty Starting Date (Parts)" then
                    if "Warranty Starting Date (Parts)" <> 0D then begin
                        if Item.Get("Item No.") and (Item."Item Tracking Code" <> '') and
                           ItemTrackingCode.Get(Item."Item Tracking Code") and
                           (Format(ItemTrackingCode."Warranty Date Formula") <> '')
                        then
                            Validate(
                              "Warranty Ending Date (Parts)",
                              CalcDate(ItemTrackingCode."Warranty Date Formula",
                                "Warranty Starting Date (Parts)"))
                        else begin
                            ServMgtSetup.Get();
                            // ServMgtSetup.Testfield("Default Warranty Duration");
                            // Validate(
                            //   "Warranty Ending Date (Parts)",
                            //   CalcDate(ServMgtSetup."Default Warranty Duration",
                            //     "Warranty Starting Date (Parts)"));
                        end;
                    end else
                        "Warranty Ending Date (Parts)" := 0D;

                if "Warranty Starting Date (Parts)" <> 0D then
                    if "Warranty Starting Date (Labor)" = 0D then
                        Validate("Warranty Starting Date (Labor)", "Warranty Starting Date (Parts)");
            end;
        }
        field(80018; "Warranty Ending Date (Parts)"; Date)
        {
            Caption = 'Warranty Ending Date (Parts)';

            trigger OnValidate()
            begin
                if "Warranty Ending Date (Parts)" < "Warranty Starting Date (Parts)" then
                    Error(
                      Text007,
                      FieldCaption("Warranty Starting Date (Parts)"), FieldCaption("Warranty Ending Date (Parts)"));

                if "Warranty Ending Date (Parts)" <> xRec."Warranty Ending Date (Parts)" then
                    MessageIfServItemLinesExist(FieldCaption("Warranty Ending Date (Parts)"));

                ServMgtSetup.Get();
                // if "Warranty % (Parts)" = 0 then
                //     "Warranty % (Parts)" := ServMgtSetup."Warranty Disc. % (Parts)";
            end;
        }
        field(80019; "Warranty % (Parts)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Warranty % (Parts)';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Warranty % (Parts)" <> xRec."Warranty % (Parts)" then
                    MessageIfServItemLinesExist(FieldCaption("Warranty % (Parts)"));
            end;
        }
        field(80020; "Warranty % (Labor)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Warranty % (Labor)';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;

            trigger OnValidate()
            begin
                if "Warranty % (Labor)" <> xRec."Warranty % (Labor)" then
                    MessageIfServItemLinesExist(FieldCaption("Warranty % (Labor)"));
            end;
        }
        field(80021; "Response Time (Hours)"; Decimal)
        {
            BlankZero = true;
            Caption = 'Response Time (Hours)';
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(80022; "Installation Date"; Date)
        {
            Caption = 'Installation Date';
        }
        field(80023; "Sales Date"; Date)
        {
            Caption = 'Sales Date';

            trigger OnValidate()
            begin
                if "Sales Date" > 0D then begin
                    if "Warranty Starting Date (Parts)" = 0D then
                        Validate("Warranty Starting Date (Parts)", "Sales Date");
                    if "Warranty Starting Date (Labor)" = 0D then
                        Validate("Warranty Starting Date (Labor)", "Sales Date");
                end;
            end;
        }
        field(80024; "Last Service Date"; Date)
        {
            Caption = 'Last Service Date';
        }
        field(80025; "Default Contract Value"; Decimal)
        {
            AutoFormatType = 2;
            BlankZero = true;
            Caption = 'Default Contract Value';
        }
        field(80026; "Default Contract Discount %"; Decimal)
        {
            BlankZero = true;
            Caption = 'Default Contract Discount %';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
        // field(80028; "No. of Active Contracts"; Integer)
        // {
        //     CalcFormula = Count("Service Contract Line" WHERE("Service Item No." = field("No."),
        //                                                        "Contract Status" = FILTER(<> Cancelled)));
        //     Caption = 'No. of Active Contracts';
        //     FieldClass = FlowField;
        // }
        field(80034; "Vendor Item No."; Code[50])
        {
            Caption = 'Vendor Item No.';
        }
        field(80048; "Item Description"; Text[100])
        {
            CalcFormula = Lookup(Item.Description WHERE("No." = field("Item No.")));
            Caption = 'Item Description';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80054; Contact; Text[100])
        {
            CalcFormula = Lookup(Customer.Contact WHERE("No." = field("Customer No.")));
            Caption = 'Contact';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80055; "Phone No."; Text[30])
        {
            CalcFormula = Lookup(Customer."Phone No." WHERE("No." = field("Customer No.")));
            Caption = 'Phone No.';
            Editable = false;
            ExtendedDatatype = PhoneNo;
            FieldClass = FlowField;
        }
        field(80056; "Ship-to Name"; Text[100])
        {
            CalcFormula = Lookup("Ship-to Address".Name WHERE("Customer No." = field("Customer No."),
                                                               Code = field("Ship-to Code")));
            Caption = 'Ship-to Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80057; "Ship-to Address"; Text[100])
        {
            CalcFormula = Lookup("Ship-to Address".Address WHERE("Customer No." = field("Customer No."),
                                                                  Code = field("Ship-to Code")));
            Caption = 'Ship-to Address';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80058; "Ship-to Address 2"; Text[50])
        {
            CalcFormula = Lookup("Ship-to Address"."Address 2" WHERE("Customer No." = field("Customer No."),
                                                                      Code = field("Ship-to Code")));
            Caption = 'Ship-to Address 2';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80059; "Ship-to Post Code"; Code[20])
        {
            CalcFormula = Lookup("Ship-to Address"."Post Code" WHERE("Customer No." = field("Customer No."),
                                                                      Code = field("Ship-to Code")));
            Caption = 'Ship-to Post Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80060; "Ship-to City"; Text[30])
        {
            CalcFormula = Lookup("Ship-to Address".City WHERE("Customer No." = field("Customer No."),
                                                               Code = field("Ship-to Code")));
            Caption = 'Ship-to City';
            Editable = false;
            FieldClass = FlowField;
            TableRelation = "Post Code".City;
            ValidateTableRelation = false;
        }
        field(80061; "Ship-to Contact"; Text[100])
        {
            CalcFormula = Lookup("Ship-to Address".Contact WHERE("Customer No." = field("Customer No."),
                                                                  Code = field("Ship-to Code")));
            Caption = 'Ship-to Contact';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80062; "Ship-to Phone No."; Text[30])
        {
            CalcFormula = Lookup("Ship-to Address"."Phone No." WHERE("Customer No." = field("Customer No."),
                                                                      Code = field("Ship-to Code")));
            Caption = 'Ship-to Phone No.';
            Editable = false;
            ExtendedDatatype = PhoneNo;
            FieldClass = FlowField;
        }
        field(80064; "Usage (Amount)"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = Sum("Service Ledger Entry"."Amount (LCY)" WHERE("Entry Type" = CONST(Usage),
                                                                           "Service Item No. (Serviced)" = field("No."),
                                                                           "Service Contract No." = field("Contract Filter"),
                                                                           "Service Order No." = field("Service Order Filter"),
                                                                           Type = field("Type Filter"),
                                                                           "Posting Date" = field("Date Filter")));
            Caption = 'Usage (Amount)';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80065; "Invoiced Amount"; Decimal)
        {
            AutoFormatType = 1;
            CalcFormula = - Sum("Service Ledger Entry"."Amount (LCY)" WHERE("Entry Type" = CONST(Sale),
                                                                            "Moved from Prepaid Acc." = CONST(true),
                                                                            "Service Item No. (Serviced)" = field("No."),
                                                                            "Service Contract No." = field("Contract Filter"),
                                                                            "Service Order No." = field("Service Order Filter"),
                                                                            Type = field("Type Filter"),
                                                                            "Posting Date" = field("Date Filter"),
                                                                            Open = CONST(false)));
            Caption = 'Invoiced Amount';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80066; "Total Quantity"; Decimal)
        {
            CalcFormula = Sum("Service Ledger Entry".Quantity WHERE("Entry Type" = CONST(Usage),
                                                                     "Service Item No. (Serviced)" = field("No."),
                                                                     "Service Contract No." = field("Contract Filter"),
                                                                     "Service Order No." = field("Service Order Filter"),
                                                                     Type = field("Type Filter"),
                                                                     "Posting Date" = field("Date Filter")));
            Caption = 'Total Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            FieldClass = FlowField;
        }
        // field(80067; "Total Qty. Invoiced"; Decimal)
        // {
        //     CalcFormula = - Sum("Service Ledger Entry"."Charged Qty." WHERE("Entry Type" = CONST(Sale),
        //                                                                     "Service Item No. (Serviced)" = field("No."),
        //                                                                     "Service Contract No." = field("Contract Filter"),
        //                                                                     "Service Order No." = field("Service Order Filter"),
        //                                                                     Type = field("Type Filter"),
        //                                                                     "Posting Date" = field("Date Filter")));
        //     Caption = 'Total Qty. Invoiced';
        //     DecimalPlaces = 0 : 5;
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
        // field(80068; "Resources Used"; Decimal)
        // {
        //     AutoFormatType = 1;
        //     CalcFormula = - Sum("Service Ledger Entry"."Cost Amount" WHERE("Service Item No. (Serviced)" = field("No."),
        //                                                                    "Entry Type" = CONST(Sale),
        //                                                                    Type = CONST(Resource),
        //                                                                    "Posting Date" = field("Date Filter")));
        //     Caption = 'Resources Used';
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
        // field(80069; "Parts Used"; Decimal)
        // {
        //     AutoFormatType = 1;
        //     CalcFormula = - Sum("Service Ledger Entry"."Cost Amount" WHERE("Service Item No. (Serviced)" = field("No."),
        //                                                                    "Entry Type" = CONST(Sale),
        //                                                                    Type = CONST(Item),
        //                                                                    "Posting Date" = field("Date Filter")));
        //     Caption = 'Parts Used';
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
        // field(80070; "Cost Used"; Decimal)
        // {
        //     AutoFormatType = 1;
        //     CalcFormula = - Sum("Service Ledger Entry"."Cost Amount" WHERE("Service Item No. (Serviced)" = field("No."),
        //                                                                    "Entry Type" = CONST(Sale),
        //                                                                    Type = CONST("Service Cost"),
        //                                                                    "Posting Date" = field("Date Filter")));
        //     Caption = 'Cost Used';
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
        field(80071; "Vendor Name"; Text[100])
        {
            CalcFormula = Lookup(Vendor.Name WHERE("No." = field("Vendor No.")));
            Caption = 'Vendor Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80072; "Vendor Item Name"; Text[100])
        {
            Caption = 'Vendor Item Name';
        }
        field(80074; "Service Item Components"; Boolean)
        {
            CalcFormula = Exist("Service Item Component" WHERE("Parent Service Item No." = field("No."),
                                                                Active = CONST(true)));
            Caption = 'Service Item Components';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80075; "Preferred Resource"; Code[20])
        {
            Caption = 'Preferred Resource';
            TableRelation = Resource."No.";

            trigger OnLookup()
            var
                Resource: Record Resource;
                SkilledResourceList: Page "Skilled Resource List";
            begin
                SkilledResourceList.Initialize(ResSkill.Type::"Service Item", "No.", Name);
                SkilledResourceList.LookupMode(true);
                if Resource.Get("Preferred Resource") then
                    SkilledResourceList.SetRecord(Resource);
                if SkilledResourceList.RunModal = ACTION::LookupOK then begin
                    SkilledResourceList.GetRecord(Resource);
                    "Preferred Resource" := Resource."No.";
                end;
            end;
        }
        field(80076; "Variant Code"; Code[10])
        {
            Caption = 'Variant Code';
            TableRelation = "Item Variant".Code WHERE("Item No." = field("Item No."));

            trigger OnValidate()
            begin
                if "Variant Code" <> xRec."Variant Code" then
                    MessageIfServItemLinesExist(FieldCaption("Variant Code"));
            end;
        }
        field(80078; "Ship-to County"; Text[30])
        {
            CalcFormula = Lookup("Ship-to Address".County WHERE("Customer No." = field("Customer No."),
                                                                 Code = field("Ship-to Code")));
            CaptionClass = '5,1,' + "Ship-to Country/Region Code";
            Caption = 'Ship-to County';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80079; "Contract Cost"; Decimal)
        {
            CalcFormula = - Sum("Service Ledger Entry"."Cost Amount" WHERE("Entry Type" = CONST(Sale),
                                                                           "Service Item No. (Serviced)" = field("No."),
                                                                           "Service Contract No." = field("Contract Filter"),
                                                                           "Service Order No." = field("Service Order Filter"),
                                                                           Type = CONST("Service Contract"),
                                                                           "Posting Date" = field("Date Filter")));
            Caption = 'Contract Cost';
            FieldClass = FlowField;
        }
        field(80082; "Ship-to Country/Region Code"; Code[10])
        {
            CalcFormula = Lookup("Ship-to Address"."Country/Region Code" WHERE("Customer No." = field("Customer No."),
                                                                                Code = field("Ship-to Code")));
            Caption = 'Ship-to Country/Region Code';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80084; "Ship-to Name 2"; Text[50])
        {
            CalcFormula = Lookup("Ship-to Address"."Name 2" WHERE("Customer No." = field("Customer No."),
                                                                   Code = field("Ship-to Code")));
            Caption = 'Ship-to Name 2';
            Editable = false;
            FieldClass = FlowField;
        }
        field(80085; "Service Price Group Code"; Code[10])
        {
            Caption = 'Service Price Group Code';
            TableRelation = "Service Price Group";
        }
        field(80086; "Default Contract Cost"; Decimal)
        {
            AutoFormatType = 2;
            BlankZero = true;
            Caption = 'Default Contract Cost';
        }
        // field(80087; "Prepaid Amount"; Decimal)
        // {
        //     AutoFormatType = 1;
        //     CalcFormula = - Sum("Service Ledger Entry"."Amount (LCY)" WHERE("Entry Type" = CONST(Sale),
        //                                                                     "Moved from Prepaid Acc." = CONST(false),
        //                                                                     "Service Item No. (Serviced)" = field("No."),
        //                                                                     "Service Contract No." = field("Contract Filter"),
        //                                                                     "Service Order No." = field("Service Order Filter"),
        //                                                                     Type = field("Type Filter"),
        //                                                                     "Posting Date" = field("Date Filter"),
        //                                                                     Open = CONST(false)));
        //     Caption = 'Prepaid Amount';
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
        field(80088; "Search Description"; Code[100])
        {
            Caption = 'Search Description';
        }
        field(80089; "Service Contracts"; Boolean)
        {
            CalcFormula = Exist("Service Contract Line" WHERE("Service Item No." = field("No.")));
            Caption = 'Service Contracts';
            Editable = false;
            FieldClass = FlowField;
        }
        // field(80090; "Total Qty. Consumed"; Decimal)
        // {
        //     CalcFormula = - Sum("Service Ledger Entry".Quantity WHERE("Entry Type" = CONST(Consume),
        //                                                               "Service Item No. (Serviced)" = field("No."),
        //                                                               "Service Contract No." = field("Contract Filter"),
        //                                                               "Service Order No." = field("Service Order Filter"),
        //                                                               Type = field("Type Filter"),
        //                                                               "Posting Date" = field("Date Filter")));
        //     Caption = 'Total Qty. Consumed';
        //     DecimalPlaces = 0 : 5;
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
        field(80101; "Type Filter"; Enum "Service Ledger Entry Type")
        {
            Caption = 'Type Filter';
            FieldClass = FlowFilter;
            // OptionCaption = ' ,Resource,Item,Service Cost,Service Contract,G/L Account';
            // OptionMembers = " ",Resource,Item,"Service Cost","Service Contract","G/L Account";
        }
        field(80102; "Contract Filter"; Code[20])
        {
            Caption = 'Contract Filter';
            FieldClass = FlowFilter;
            TableRelation = "Service Contract Header"."Contract No." WHERE("Contract Type" = CONST(Contract));
        }
        field(80103; "Service Order Filter"; Code[20])
        {
            Caption = 'Service Order Filter';
            FieldClass = FlowFilter;
            TableRelation = "Service Header"."No.";
        }
        field(80104; "Sales/Serv. Shpt. Document No."; Code[20])
        {
            Caption = 'Sales/Serv. Shpt. Document No.';
            TableRelation = IF ("Shipment Type" = CONST(Sales)) "Sales Shipment Line"."Document No."
            ELSE
            IF ("Shipment Type" = CONST(Service)) "Service Shipment Line"."Document No.";
        }
        field(80105; "Sales/Serv. Shpt. Line No."; Integer)
        {
            Caption = 'Sales/Serv. Shpt. Line No.';
            TableRelation = IF ("Shipment Type" = CONST(Sales)) "Sales Shipment Line"."Line No." WHERE("Document No." = field("Sales/Serv. Shpt. Document No."))
            ELSE
            IF ("Shipment Type" = CONST(Service)) "Service Shipment Line"."Line No." WHERE("Document No." = field("Sales/Serv. Shpt. Document No."));
        }
        field(80106; "Shipment Type"; Option)
        {
            Caption = 'Shipment Type';
            OptionCaption = 'Sales,Service';
            OptionMembers = Sales,Service;
        }
    }


    trigger OnDelete()
    var
        ResultDescription: Text;
    begin
        // MoveEntries.MoveServiceItemLedgerEntries(Rec);

        // ResultDescription := CheckIfCanBeDeleted;
        // if ResultDescription <> '' then
        //     Error(ResultDescription);

        // DeleteServItemComponents;

        // ServCommentLine.Reset();
        // ServCommentLine.SetRange("Table Name", ServCommentLine."Table Name"::"Service Item");
        // ServCommentLine.SetRange("Table Subtype", 0);
        // ServCommentLine.SetRange("No.", "No.");
        // ServCommentLine.DeleteAll();

        // ResSkillMgt.DeleteServItemResSkills("No.");
        // ServLogMgt.ServItemDeleted("No.");

        // DimMgt.DeleteDefaultDim(DATABASE::"Service Item", "No.");
    end;

    trigger OnInsert()
    begin
        ServMgtSetup.Get();
        if ("No." = '') And (Type = Type::Machine) then begin
            ServMgtSetup.Testfield("Producto Servicio");
            NoSeriesMgt.InitSeries(ServMgtSetup."Producto Servicio", xRec."No. Series", 0D, "No.", "No. Series");
        end;
        //"Response Time (Hours)" := ServMgtSetup."Default Response Time (Hours)";

        //ServLogMgt.ServItemCreated(Rec);
    end;

    trigger OnRename()
    begin
        if "No." <> xRec."No." then begin
            DimMgt.RenameDefaultDim(DATABASE::Resource, xRec."No.", "No.");
            //  ServLogMgt.ServItemNoChange(Rec, xRec);
            // ServContractLine.Reset();
            // ServContractLine.SetCurrentKey("Service Item No.", "Contract Status");
            // ServContractLine.SetRange("Service Item No.", xRec."No.");
            // ServContractLine.SetRange("Contract Type", ServContractLine."Contract Type"::Contract);
            // if ServContractLine.Find('-') then
            //     repeat
            //         ContractChangeLog.LogContractChange(
            //           ServContractLine."Contract No.", 1,
            //           ServContractLine.FieldCaption("Service Item No."), 3,
            //           xRec."No.", "No.", "No.", 0);
            //     until ServContractLine.Next() = 0;
        end;
    end;

    var
        Text000: Label 'You cannot delete %1 %2,because it is attached to a service order.';
        Text001: Label 'You cannot delete %1 %2, because it is used as %3 for %1 %4.';
        Text002: Label 'You cannot delete %1 %2, because it belongs to one or more contracts.';
        Text003: Label '%1 %2 already exists in %3 %4.';
        Text004: Label 'You cannot change %1 %2 because the %3 %4 belongs to one or more contracts.';
        Text007: Label '%1 cannot be later than %2.';
        FieldUpdateConfirmQst: Label 'You have changed %1 on the service item, but it has not been changed on the associated service orders/quotes.\You must update them manually.', Comment = '%1 = field name';
        ServMgtSetup: Record "Sales & Receivables Setup";
        ServItem: Record Resource;
        // ServItemGr: Record "Service Item Group";
        // ServContract: Record "Service Contract Header";
        // ServContractLine: Record "Service Contract Line";
        // ServCommentLine: Record "Service Comment Line";
        Item: Record Item;
        ContractChangeLog: Record "Contract Change Log";
        // ServLedgEntry: Record "Service Ledger Entry";
        // ServItemLine: Record "Service Item Line";
        // ServItemComponent: Record "Service Item Component";
        ResSkill: Record "Resource Skill";
        Currency: Record Currency;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        // ServLogMgt: Codeunit ServLogManagement;
        // MoveEntries: Codeunit MoveEntries;
        ResSkillMgt: Codeunit "Resource Skill Mgt.";
        Text017: Label 'Service ledger entries exist for this %1\\ Do you want to change the %2?';
        DimMgt: Codeunit DimensionManagement;
        CancelResSkillChanges: Boolean;
        CancelResSkillAssignment: Boolean;
        ChgCustomerErr: Label 'You cannot change the %1 in the service item because of the following outstanding service order line:\\ Order %2, line %3, service item number %4, serial number %5, customer %6, ship-to code %7.', Comment = '%1 - Field Caption; %2 - Service Order No.;%3 - Serice Line No.;%4 - Service Item No.;%5 - Serial No.;%6 - Customer No.;%7 - Ship to Code.';
        ChangeItemQst: Label 'Changing the %1 will delete the existing %2 on the %2 list.\\Do you want to change the %1?', Comment = '%1 - Field Caption, %2 - Field Caption';


    local procedure ServItemLinesExist(): Boolean
    begin
        // ServItemLine.Reset();
        // ServItemLine.SetCurrentKey("Service Item No.");
        // ServItemLine.SetRange("Service Item No.", "No.");
        // exit(ServItemLine.FindFirst);
    end;

    procedure MessageIfServItemLinesExist(ChangedFieldName: Text[100])
    var
        MessageText: Text;
        ShowMessage: Boolean;
    begin
        ShowMessage := ServItemLinesExist;
        MessageText := StrSubstNo(FieldUpdateConfirmQst, ChangedFieldName);
        // OnBeforeMessageIfServItemLinesExist(Rec, ChangedFieldName, MessageText, ShowMessage);
        if ShowMessage then
            Message(MessageText);
    end;

    local procedure DeleteServItemComponents()
    begin
        // ServItemComponent.Reset();
        // ServItemComponent.SetRange("Parent Service Item No.", "No.");
        // ServItemComponent.DeleteAll();

        // OnAfterDeleteServItemComponents(Rec);
    end;

    local procedure ServItemLinesExistErr(ChangedFieldName: Text[100])
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        //OnBeforeServItemLinesExistErr(Rec, ChangedFieldName, IsHandled);
        if IsHandled then
            exit;

        // if ServItemLinesExist then
        //     Error(
        //       ChgCustomerErr,
        //       ChangedFieldName,
        //       ServItemLine."Document No.", ServItemLine."Line No.", ServItemLine."Service Item No.",
        //       ServItemLine."Serial No.", ServItemLine."Customer No.", ServItemLine."Ship-to Code");
    end;

    local procedure ServLedgEntryExist(): Boolean
    begin
        // ServLedgEntry.Reset();
        // ServLedgEntry.SetCurrentKey(
        //   "Service Item No. (Serviced)", "Entry Type", "Moved from Prepaid Acc.",
        //   Type, "Posting Date", Open);
        // ServLedgEntry.SetRange("Service Item No. (Serviced)", "No.");
        // exit(ServLedgEntry.FindFirst);
    end;

    // local procedure CheckifActiveServContLineExist(): Boolean
    // begin
    //     ServContractLine.Reset();
    //     ServContractLine.SetCurrentKey("Service Item No.", "Contract Status");
    //     ServContractLine.SetRange("Service Item No.", "No.");
    //     ServContractLine.SetFilter("Contract Status", '<>%1', ServContractLine."Contract Status"::Cancelled);
    //     exit(ServContractLine.Find('-'));
    // end;

    // procedure CheckIfCanBeDeleted() Result: Text
    // var
    //     ServiceLedgerEntry: Record "Service Ledger Entry";
    //     IsHandled: Boolean;
    // begin
    //     IsHandled := false;
    //     OnBeforeCheckIfCanBeDeleted(Rec, Result, IsHandled);
    //     if IsHandled then
    //         exit(Result);

    //     if ServItemLinesExist then
    //         exit(
    //           StrSubstNo(
    //             Text000,
    //             TableCaption, "No."));

    //     ServItemComponent.Reset();
    //     ServItemComponent.SetCurrentKey(Type, "No.", Active);
    //     ServItemComponent.SetRange(Type, ServItemComponent.Type::"Service Item");
    //     ServItemComponent.SetRange("No.", "No.");
    //     if ServItemComponent.FindFirst then
    //         exit(
    //           StrSubstNo(
    //             Text001,
    //             TableCaption, "No.", ServItemComponent.TableCaption, ServItemComponent."Parent Service Item No."));

    //     ServContractLine.Reset();
    //     ServContractLine.SetCurrentKey("Service Item No.", "Contract Status");
    //     ServContractLine.SetRange("Service Item No.", "No.");
    //     ServContractLine.SetFilter("Contract Status", '<>%1', ServContractLine."Contract Status"::Cancelled);
    //     if ServContractLine.Find('-') then
    //         if ServContract.Get(ServContractLine."Contract Type", ServContractLine."Contract No.") then
    //             exit(
    //               StrSubstNo(Text002, TableCaption, "No."));

    //     exit(MoveEntries.CheckIfServiceItemCanBeDeleted(ServiceLedgerEntry, "No."));
    // end;

    procedure OmitAssignResSkills(IsSetOmitted: Boolean)
    begin
        CancelResSkillAssignment := IsSetOmitted;
    end;

    // [IntegrationEvent(false, false)]
    // local procedure OnAfterAssignItemValues(var ServiceItem: Record "Service Item"; var xServiceItem: Record "Service Item"; Item: Record Item; CurrFieldNo: Integer)
    // begin
    // end;

    // [IntegrationEvent(false, false)]
    // local procedure OnAfterDeleteServItemComponents(var ServiceItem: Record "Service Item")
    // begin
    // end;

    // [IntegrationEvent(false, false)]
    // local procedure OnBeforeMessageIfServItemLinesExist(ServiceItem: Record "Service Item"; ChangedFieldName: Text[100]; var MessageText: Text; var ShowMessage: Boolean)
    // begin
    // end;

    // [IntegrationEvent(false, false)]
    // local procedure OnBeforeServItemLinesExistErr(var ServiceItem: Record "Service Item"; ChangedFieldName: Text[100]; var IsHandled: Boolean)
    // begin
    // end;

    // [IntegrationEvent(false, false)]
    // local procedure OnBeforeCheckIfCanBeDeleted(var ServiceItem: Record "Service Item"; var Result: Text; var IsHandled: Boolean)
    // begin
    // end;
}

