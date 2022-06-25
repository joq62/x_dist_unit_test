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
-module(dist_leader).   
 
-export([start/1
	]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
start(StartNodesInfo)->
    ApplIdToStart=["common","sd"],
    dist_node_test_node:load_start_appl(StartNodesInfo,ApplIdToStart),
    [rpc:call(Node,application,set_env,[[{leader,[{application_to_track,sd}]}]],5000)||{ok,Node,NodeDir}<-StartNodesInfo],
    dist_node_test_node:load_start_appl(StartNodesInfo,["leader"]),
    check_leader().
    
check_leader()->
    case sd:get(leader) of
	[]->
	    io:format("No leaders ~p~n",[{?MODULE,?LINE}]);
	Nodes->
	    io:format("who is leader ~p~n",[{?MODULE,?LINE,[{rpc:call(Node,leader,who_is_leader,[],5000),Node}||{Node,_}<-Nodes]}])
		
    end,
    timer:sleep(20*1000),    
    check_leader().




