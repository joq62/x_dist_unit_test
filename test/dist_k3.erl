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
-module(dist_k3).   
 
-export([test/0
	]).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------

%% --------------------------------------------------------------------
%% Function: available_hosts()
%% Description: Based on hosts.config file checks which hosts are avaible
%% Returns: List({HostId,Ip,SshPort,Uid,Pwd}
%% --------------------------------------------------------------------
test()->
    
    case lists:sort(sd:get(k3)) of
	[{cl_test_landet_node@c100,"c100"},
	 {cl_test_landet_node@c200,"c200"},
	 {cl_test_landet_node@c202,"c202"}]->
	    io:format("All Nodes running !!~p~n",[{?MODULE,?LINE}]);
	RunningNodes->
	    case sd:get(leader) of
		[]->
		    ok;
		Nodes->
		    io:format("who is leader ~p~n",[{?MODULE,?LINE,[{rpc:call(Node,leader,who_is_leader,[],5000),Node}||{Node,_}<-Nodes]}])
	    end,
	    io:format("Not all running ~p~n",[{?MODULE,?LINE,RunningNodes}]),   
	    timer:sleep(20*1000),
	    test()
    end,
    timer:sleep(20*1000),
    case sd:get(leader) of
	[]->
	    ok;
	Nodes2->
	    io:format("who is leader ~p~n",[{?MODULE,?LINE,[{rpc:call(Node,leader,who_is_leader,[],5000),Node}||{Node,_}<-Nodes2]}])
    end,
    io:format("sd:all() ~p~n",[{?MODULE,?LINE,sd:all()}]),   
    test().
    
       




