%%% -------------------------------------------------------------------
%%% Author  : uabjle
%%% Description : resource discovery accroding to OPT in Action 
%%% This service discovery is adapted to 
%%% Type = application 
%%% Instance ={ip_addr,{IP_addr,Port}}|{erlang_node,{ErlNode}}
%%% 
%%% Created : 10 dec 2012
%%% -------------------------------------------------------------------
-module(basic_eunit).

-behaviour(gen_server). 

%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
-define(WAIT_FOR_ELECTION_RESPONSE_TIMEOUT,2*1000).

-define(SERVER,?MODULE).

%% External exports
-export([
	 eunit/1,
	 start_test/0,
	 ping/0
	]).

-export([start/0,
	 stop/0]).


%% gen_server callbacks



-export([init/1, handle_call/3,handle_cast/2, handle_info/2, terminate/2, code_change/3]).

-record(state, {}).

%% ====================================================================
%% External functions
%% ====================================================================
start_test()->
    application:start(?MODULE).


start()-> gen_server:start_link({local, ?SERVER}, ?SERVER, [], []).
stop()-> gen_server:call(?SERVER, {stop},infinity).


ping()-> gen_server:call(?SERVER, {ping},infinity).


eunit(TestModule)->
    gen_server:call(?SERVER, {eunit,TestModule},infinity).
%% ====================================================================
%% Server functions
%% ====================================================================

%% --------------------------------------------------------------------
%% Function: init/1
%% Description: Initiates the server
%% Returns: {ok, State}          |
%%          {ok, State, Timeout} |
%%          ignore               |
%%          {stop, Reason}
%% --------------------------------------------------------------------
init([]) ->
    {ok,TestModule}=application:get_env(module),
    rpc:cast(node(),?MODULE,eunit,[TestModule]),
    io:format("TestModule to test  ~p~n",[{?MODULE,?LINE,TestModule}]),
    x_dist_cookie=erlang:get_cookie(),
    {ok, #state{}}.

%% --------------------------------------------------------------------
%% Function: handle_call/3
%% Description: Handling call messages
%% Returns: {reply, Reply, State}          |
%%          {reply, Reply, State, Timeout} |
%%          {noreply, State}               |
%%          {noreply, State, Timeout}      |
%%          {stop, Reason, Reply, State}   | (terminate/2 is called)
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------


handle_call({eunit,config},_From, State) ->
    Reply=ok = config_eunit:start(),
    {reply, Reply, State};

handle_call({eunit,common},_From, State) ->
    Reply=ok = common_eunit:start(),
    {reply, Reply, State};

handle_call({eunit,node},_From, State) ->
    ok=step1_start_basic_appl(),
    ok=node:appl_start([]),
    StartNodesInfo=dist_node_test_node:create_host_nodes(["c100","c200","c202"]),
    ApplIdToStart=["common","sd"],
    Reply=dist_node_test_node:load_start_appl(StartNodesInfo,ApplIdToStart),
    dist_node_test_node:cleanup(StartNodesInfo),
    io:format("sd:all()  ~p~n",[{?MODULE,?LINE,sd:all()}]),
    {reply, Reply, State};

handle_call({eunit,leader},_From, State) ->
    ok=step1_start_basic_appl(),
    ok=node:appl_start([]),
    StartNodesInfo=dist_node_test_node:create_host_nodes(["c100","c200","c202"]),
    dist_leader:start(StartNodesInfo),
    dist_node_test_node:cleanup(StartNodesInfo),
    io:format("sd:all()  ~p~n",[{?MODULE,?LINE,sd:all()}]),
    Reply=ok,
    {reply, Reply, State};

handle_call({eunit,k3},_From, State) ->

    ok=application:start(nodelog),
    LogDir="logs",
    LogFileName="cluster.log",
    ok=file:make_dir(LogDir),
    LogFile=filename:join([LogDir,LogFileName]),
    nodelog:create(LogFile),    
    ok=application:start(sd),
    ok=application:start(node),
    ok=application:start(config),
 
    ok=etcd:appl_start([]),
    pong=etcd:ping(), 
    ok=etcd:dynamic_db_init([]),
    ok=db_host_spec:init_table(),
    ok=db_application_spec:init_table(),
    ok=db_deployment_info:init_table(),
    ok=db_deployments:init_table(),
    DeploymentName="cl_test_landet",  
    ok=application:set_env([{k3,[{deployment_name,DeploymentName}]}]),
    HostStartResult=rpc:call(node(),k3_remote_host,start_k3,[DeploymentName],25*5000),
  io:format("HostStartResult ~p~n",[{HostStartResult,?FUNCTION_NAME,?MODULE,?LINE}]),
  %  ok=k3:appl_start([]),
    Reply=dist_k3:test(),
    {reply, Reply, State};

handle_call({eunit,TestModule},_From, State) ->
    Reply = {error,[not_implemented,TestModule]},
    {reply, Reply, State};


handle_call({ping},_From, State) ->
    Reply = pong,
    {reply, Reply, State};

handle_call({ping},_From, State) ->
    Reply = pong,
    {reply, Reply, State};

handle_call({stop}, _From, State) ->
    {stop, normal, shutdown_ok, State};

handle_call(Request, From, State) ->
    Reply = {unmatched_signal,?MODULE,Request,From},
    {reply, Reply, State}.

%% --------------------------------------------------------------------
%% Function: handle_cast/2
%% Description: Handling cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------



handle_cast(Msg, State) ->
    io:format("unmatched match cast ~p~n",[{Msg,?FUNCTION_NAME,?MODULE,?LINE}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: handle_info/2
%% Description: Handling all non call/cast messages
%% Returns: {noreply, State}          |
%%          {noreply, State, Timeout} |
%%          {stop, Reason, State}            (terminate/2 is called)
%% --------------------------------------------------------------------

handle_info(Info, State) ->
    io:format("unmatched match Info ~p~n",[{Info,?FUNCTION_NAME,?MODULE,?LINE}]),
    {noreply, State}.

%% --------------------------------------------------------------------
%% Function: terminate/2
%% Description: Shutdown the server
%% Returns: any (ignored by gen_server)
%% --------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.

%% --------------------------------------------------------------------
%% Func: code_change/3
%% Purpose: Convert process state when code is changed
%% Returns: {ok, NewState}
%% --------------------------------------------------------------------
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%% --------------------------------------------------------------------
%%% Exported functions
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%%% Internal functions
%% --------------------------------------------------------------------
%%---------------------------------------------------------------
%% Function:load_appl(App)
%% @doc: loads latest version of App to vm Vm      
%% @param: Application and erlang vm to load 
%% @returns:ok|{error,Reason}
%%
%%---------------------------------------------------------------



%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------
step1_start_basic_appl()->
    ok=application:start(nodelog),
    %% Init logging 
    LogDir="logs",
    LogFileName="cluster.log",
    ok=file:make_dir(LogDir),
    LogFile=filename:join([LogDir,LogFileName]),
    nodelog:create(LogFile),    
    ok=application:start(sd),
    ok=application:start(config),
    ok=etcd:appl_start([]),
    pong=etcd:ping(), 
    ok=etcd:dynamic_db_init([]),
    ok=db_host_spec:init_table(),
    ok=db_application_spec:init_table(),
    ok=db_deployment_info:init_table(),
    ok=db_deployments:init_table(),
    ok.
