# Cookbook Name:: chef_classroom
# Recipe:: _setup_security_groups

require 'chef/provisioning/aws_driver'
with_driver "aws::#{region}"
name = node['chef_classroom']['class_name']

aws_security_group "training-#{name}-workstations" do
  action :create
  ignore_failure true
  inbound_rules class_source_addr         => [22],
                node['ec2']['local_ipv4'] => [22]   if type == 'linux'
  inbound_rules class_source_addr         => [3389],
                node['ec2']['local_ipv4'] => [22]   if type == 'windows'
end

aws_security_group "training-#{name}-nodes" do
  action :create
  ignore_failure true
  inbound_rules "training-#{name}-workstations" => [22, 5985, 5986],
                node['ec2']['local_ipv4']       => [22, 3389, 5985, 5986],
                class_source_addr               => [22, 3389, 5985, 5986]
end

aws_security_group "training-#{name}-chef_server" do
  action :create
  ignore_failure true
  inbound_rules class_source_addr         => [80, 443],
                "training-#{name}-nodes"  => [443],
                node['ec2']['local_ipv4'] => [22]
end
