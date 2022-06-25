%%% -------------------------------------------------------------------
%%% @author  : Joq Erlang
%%% @doc: : 
%%% Created :
%%% Node end point  
%%% Creates and deletes Pods
%%% 
%%% API-kube: Interface 
%%% Pod consits beams from all services, app and app and sup erl.
%%% The setup of envs is
%%% -------------------------------------------------------------------
-module(dist_node_test_node).   
 
-export([create_host_nodes/1,
	 load_start_appl/2,
	 cleanup/1
	]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
create_host_nodes(Hosts)->
    
    NodeName="cl_test_landet_node",
    CookieStr=atom_to_list(erlang:get_cookie()),
 %   xx=CookieStr,
    PaArgs=" ",
    EnvArgs=" ",
    NodeDirBase="node.test_dir",
    StartedNodesInfo=[create_node(HostName,NodeName,CookieStr,PaArgs,EnvArgs,NodeDirBase)||HostName<-Hosts],
    %gl=StartedNodesInfo,
    [{cl_test_landet_node@c100,"c100"},
     {cl_test_landet_node@c200,"c200"},
     {cl_test_landet_node@c202,"c202"},
     {x_dist_test@c100,"c100"}]=lists:sort(sd:get(kernel)),

    StartedNodesInfo.

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------
%StartNodesInfo={ok,Node,NodeDir}

load_start_appl([],[])->
    ok;
load_start_appl(_,[]) ->
    ok;
load_start_appl([],_) ->
    ok;
load_start_appl([{ok,Node,NodeDir}|T],ApplIdList) ->
    [load_start_appl(Node,NodeDir,ApplId)||ApplId<-ApplIdList],
    load_start_appl(T,ApplIdList).

load_start_appl(Node,NodeDir,ApplId)->
    {ok,ApplId,Vsn,ApplDir}=node:load_start_appl(Node,NodeDir,ApplId),
    Appl=list_to_atom(ApplId),
    pong=rpc:call(Node,Appl,ping,[],5000),
 io:format("ok,ApplId ~p~n",[{?MODULE,?LINE,ok,Node, ApplId}]),   
    {ok,ApplId} .

%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% --------------------------------------------------------------------

cleanup([])->
    ok;
cleanup([{ok,Node,NodeDir}|T])->
    rpc:call(Node,os,cmd,["rm -rf  "++NodeDir],5000),
    false= rpc:call(Node,filelib,is_dir,[NodeDir],5000),
    rpc:call(Node,init,stop,[],1000),
    cleanup(T).
%% --------------------------------------------------------------------
%% Function:start/0 
%% Description: Initiate the eunit tests, set upp needed processes etc
%% Returns: non
%% -------------------------------------------------------------------

create_node(HostName,NodeName,CookieStr,PaArgs,EnvArgs,NodeDirBase)->
    {ok,Node}=node:ssh_create(HostName,NodeName,CookieStr,PaArgs,EnvArgs),
    {ok,Cwd}=rpc:call(Node,file,get_cwd,[],5000),
    NodeDir=filename:join(Cwd,NodeDirBase),
    []=rpc:call(Node,os,cmd,["rm -rf "++NodeDir],5000),
    timer:sleep(2000),
    ok=rpc:call(Node,file,make_dir,[NodeDir],5000),
    rpc:cast(node(),nodelog,log,[notice,?MODULE_STRING,?LINE,
						       {"Ok, created node at host",Node,HostName}]),
    {ok,Node,NodeDir}.
