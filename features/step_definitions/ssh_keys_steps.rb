require 'fileutils'
require 'ruby-debug'
Debugger.start

#########
# GIVEN
#########

Given /^the following hosts$/ do |string|
  hosts = StringIO.new(string)
  @muggle = SSHMuggle::parse hosts
end

Given /^the following keys are on the servers$/ do |table|
  keys = server_with_keys_from_table(table)
  
  keys.each do |host, keys|
    File.open(fake_server_dir!(host) + '/authorized_keys', 'w+') do |file|
      file.write(keys.join("\n"))
    end
  end
end

Given /^the following keys have been fetched$/ do |table|
  Given 'the server "localhost"'
  @muggle.keys = table.rows.flatten
end

Given /^the server "([^\"]*)" without a key file$/ do |servername|
    Given "the server \"localhost\""
end

Given /^the server "([^\"]*)"$/ do |servername|
  @muggle = SSHMuggle::Server.new(servername)
end

#########
# WHEN
#########

When /^I run the fetch_keys command for the server "([^\"]*)"$/ do |hostname|
  @muggle = SSHMuggle::Server.new(hostname)
  @muggle.fetch_keys
end

When /^I add the key "([^\"]*)"$/ do |key|
  @muggle.keys << key
end

When /^I run the (.*) command$/ do |command|
  @muggle.send(command)
end

When /^I upload the keys to the server "([^\"]*)"$/ do |servername, table|
  @muggle = SSHMuggle::Server.new(servername)
  @muggle.keys = table.rows
  @muggle.upload_keys
end

#########
# THEN
#########

Then /^It should fetch the following keys$/ do |table|
  actual_keys = [['key']] | @muggle.keys.map {|key| [key] }
  table.diff!(actual_keys)
end

Then /^It should generate the following files$/ do |keyfiles|
  actual_keyfiles = [['name', 'key']]
  Dir[TEST_TMP_PATH + '/keys/*.pub'].each do |keyfile|
    File.open(keyfile) do |file|
      actual_keyfiles << [File.basename(keyfile), file.read.strip]
    end
  end

  keyfiles.diff!(actual_keyfiles)
end

Then /^the server "([^\"]*)" should have the authorized_keys file with the content$/ do |server, expected_content|
  File.read(TEST_TMP_PATH + "/servers/#{server}/authorized_keys").should == expected_content
end

Then /^the following keys should be on the servers$/ do |table|
  actual_keys_from_server = [['server', 'key']]
  server_with_keys_from_table(table).each do |server, keys|
    entries = File.read(TEST_TMP_PATH + "/servers/#{server}/authorized_keys").split("\n").map {|key| [server, key]}
    actual_keys_from_server += entries
  end
  table.diff!(actual_keys_from_server)
end

#########
# HELPER
#########
def fake_server_dir!(server)
  path = fake_server_dir(server)
  return path if File.directory?(path)
  FileUtils.mkdir_p path
  path
end

def fake_server_dir(host)
  TEST_TMP_PATH + "/servers/#{host}"
end

def server_with_keys_from_table(table)
  keys = {}
  table.hashes.each do |values|
    keys[values["server"]] ||= []
    keys[values["server"]] << values["key"]
  end
  keys
end