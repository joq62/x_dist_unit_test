all:
	rm -rf  *~ */*~  test/*.beam erl_cra*;
	rm -rf  cluster* logs *.pod_dir rebar.lock;
	rm -rf _build test_ebin ebin
	rm -rf deployments temp *_info_specs;
	echo Done
eunit:
	rm -rf  *~ */*~ test/*.beam test_ebin erl_cra*;
	rm -rf _build logs log *.pod_dir
	rm -rf deployments host_info_specs;
	rm -rf rebar.lock;
	rm -rf ebin;
#	host_info_specs dir and deployments dir shall be installed once
	rm -rf  *~ */*~ apps/k3/src/*.beam test/*.beam test_ebin erl_cra*;
	rm -rf _build logs log *.pod_dir
	rm -rf deployments *_info_specs;
	rm -rf rebar.lock;
	rm -rf ebin;
#	host_info_specs dir and deployments dir shall be installed once
	mkdir  host_info_specs;
	cp ../../specifications/host_info_specs/*.host host_info_specs;
	git clone https://github.com/joq62/deployments.git;
	git clone https://github.com/joq62/application_info_specs.git;
	git clone https://github.com/joq62/deployment_info_specs.git;
#	Delete and create new cluster dir to make a clean start
	mkdir ebin;
#	common
	erlc -o ebin /home/joq62/erlang/infra_2/common/src/*.erl;
	erlc -o ebin /home/joq62/erlang/infra_2/common/test/common_eunit.erl;
	cp /home/joq62/erlang/infra_2/common/src/common.app.src ebin/common.app;
#	config
	erlc -o ebin /home/joq62/erlang/infra_2/config/apps/config/src/*.erl;
	erlc -o ebin /home/joq62/erlang/infra_2/config/test/config_eunit.erl;
	cp /home/joq62/erlang/infra_2/config/apps/config/src/config.app.src ebin/config.app;
#	sd
	erlc -o ebin /home/joq62/erlang/infra_2/sd/apps/sd/src/*.erl;
	erlc -o ebin /home/joq62/erlang/infra_2/sd/test/sd_eunit.erl;
	cp /home/joq62/erlang/infra_2/sd/apps/sd/src/sd.app.src ebin/sd.app;
#	node
	erlc -o ebin /home/joq62/erlang/infra_2/node/src/*.erl;
	erlc -o ebin /home/joq62/erlang/infra_2/node/test/node_eunit.erl;
	cp /home/joq62/erlang/infra_2/node/src/node.app.src ebin/node.app;
#	nodelog
	erlc -o ebin /home/joq62/erlang/infra_2/nodelog/src/*.erl;
	erlc -o ebin /home/joq62/erlang/infra_2/nodelog/test/nodelog_eunit.erl;
	cp /home/joq62/erlang/infra_2/nodelog/src/nodelog.app.src ebin/nodelog.app;
#	etcd
	erlc -o ebin /home/joq62/erlang/infra_2/etcd/src/*.erl;
	erlc -o ebin /home/joq62/erlang/infra_2/etcd/test/etcd_eunit.erl;
	cp /home/joq62/erlang/infra_2/etcd/src/etcd.app.src ebin/etcd.app;
#	leader
	erlc -o ebin /home/joq62/erlang/infra_2/leader/src/*.erl;
	erlc -o ebin /home/joq62/erlang/infra_2/leader/test/leader_eunit.erl;
	cp /home/joq62/erlang/infra_2/leader/src/leader.app.src ebin/leader.app;
#	k3
	erlc -o ebin /home/joq62/erlang/infra_2/k3/apps/k3/src/*.erl;
	erlc -o ebin /home/joq62/erlang/infra_2/k3/test/k3_eunit.erl;
	cp /home/joq62/erlang/infra_2/k3/apps/k3/src/k3.app.src ebin/k3.app;
#	testing
	mkdir test_ebin;
	erlc -o test_ebin test/*.erl;
	erl -pa * -pa ebin -pa test_ebin -sname x_dist_test -run basic_eunit start_test\
	    -setcookie x_dist_cookie\
	    -basic_eunit module $(module)
