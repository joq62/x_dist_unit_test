%% This is the application resource file (.app file) for the 'base'
%% application.
{application, basic_eunit,
[{description, "Basic_Eunit application and cluster" },
{vsn, "1.0.0" },
{modules, 
	  [basic_eunit_app,basic_eunit,basic_eunit_sup,appfile,lib_basic_eunit]},
{registered,[basic_eunit]},
{applications, [kernel,stdlib]},
{mod, {basic_eunit_app,[]}},
{start_phases, []}
]}.
