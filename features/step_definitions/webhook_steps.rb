When /^I have added a webhook for "([^\"]*)" to gem "([^\"]*)" with my api key$/ do |web_hook_url, gem_name|
  WebMock.stub_request(:post, web_hook_url)
  header("Authorization", @api_key)
  visit api_v1_web_hooks_path, :post, :gem_name => gem_name, :url => web_hook_url
end

When /^I have added a global webhook for "([^\"]*)" with my api key$/ do |web_hook_url|
  WebMock.stub_request(:post, web_hook_url)
  header("Authorization", @api_key)
  visit api_v1_web_hooks_path, :post, :gem_name => '*', :url => web_hook_url
end

When /^I list the webhooks with my api key$/ do
  header("Authorization", @api_key)
  visit api_v1_web_hooks_path, :get
end

Then /^the webhook "([^\"]*)" should receive a POST with gem "([^\"]*)" at version "([^\"]*)"$/ do |web_hook_url, gem_name, version_number|
  WebMock.assert_requested(:post, web_hook_url, :times => 1)

  request = WebMock::RequestRegistry.instance.requested_signatures.hash.keys.first
  json = ActiveSupport::JSON.decode(request.body)

  assert_equal gem_name, json["name"]
  assert_equal version_number, json["version"]
end

Then /^I should see "([^\"]*)" under the "([^\"]*)" gem$/ do |web_hook_url, gem_name|
  json = ActiveSupport::JSON.decode(response.body)
  assert json[gem_name].find { |hook| hook['url'] == web_hook_url }
end
