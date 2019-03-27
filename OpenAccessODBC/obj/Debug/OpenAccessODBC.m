﻿// This file contains your Data Connector logic
section OpenAccessODBC;

/* This is the method for connection to ODBC*/
[DataSource.Kind="OpenAccessODBC", Publish="OpenAccessODBC.Publish"]
shared OpenAccessODBC.Database = (dsn as text) as table =>
      let
        //
        // Connection string settings
        //
        ConnectionString = [
            DSN=dsn
        ],

        //
        // Handle credentials
        // Credentials are not persisted with the query and are set through a separate 
        // record field - CredentialConnectionString. The base Odbc.DataSource function
        // will handle UsernamePassword authentication automatically, but it is explictly
        // handled here as an example. 
        //
        Credential = Extension.CurrentCredential(),
        encryptionEnabled = Credential[EncryptConnection]? = true,
		CredentialConnectionString = [
            SSLMode = if encryptionEnabled then "verify-full" else "require",
            UID = Credential[Username],
            PWD = Credential[Password],
            BoolsAsChar = 0,
            MaxVarchar = 65535
        ],
        //
        // Call to Odbc.DataSource
        //
        OdbcDatasource = Odbc.DataSource(ConnectionString, [
            HierarchicalNavigation = true,
            TolerateConcatOverflow = true,
            // These values should be set by previous steps
            CredentialConnectionString = CredentialConnectionString,
            SqlCapabilities = [
                SupportsTop = true,
                Sql92Conformance = 8,
                SupportsNumericLiterals = true,
                SupportsStringLiterals = true,
                SupportsOdbcDateLiterals = true,
                SupportsOdbcTimeLiterals = true,
                SupportsOdbcTimestampLiterals = true
            ],
            SQLGetFunctions = [
                // Disable using parameters in the queries that get generated.
                // We enable numeric and string literals which should enable literals for all constants.
                SQL_API_SQLBINDPARAMETER = false
            ]
        ])
        
    in OdbcDatasource;


// Data Source Kind description
OpenAccessODBC = [
 // Test Connection
    TestConnection = (dataSourcePath) => 
        let
            json = Json.Document(dataSourcePath),
            dsn = json[dsn]
        in
            { "OpenAccessODBC.Database", dsn}, 
 // Authentication Type
    Authentication = [
        UsernamePassword = [],
        Implicit = []
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// Data Source UI publishing description
OpenAccessODBC.Publish = [
    Category = "Database",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://powerbi.microsoft.com/",
    SourceImage = OpenAccessODBC.Icons,
    SourceTypeImage = OpenAccessODBC.Icons,
    // This is for Direct Query Support
    SupportsDirectQuery = true
];

OpenAccessODBC.Icons = [
    Icon16 = { Extension.Contents("OpenAccessODBC16.png"), Extension.Contents("OpenAccessODBC20.png"), Extension.Contents("OpenAccessODBC24.png"), Extension.Contents("OpenAccessODBC32.png") },
    Icon32 = { Extension.Contents("OpenAccessODBC32.png"), Extension.Contents("OpenAccessODBC40.png"), Extension.Contents("OpenAccessODBC48.png"), Extension.Contents("OpenAccessODBC64.png") }
];

