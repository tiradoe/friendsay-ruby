#!/usr/bin/env ruby
require "net/http"
require "json"
require "yaml"

CONFIG = YAML.safe_load(File.read("config.yaml"))
SURVEY_ID = CONFIG["survey_id"]
API_TOKEN = CONFIG["api_token"]
API_SECRET = CONFIG["api_secret"]
JSON_PATH = CONFIG["json_path"]
NAME_QID = "3"
MESSAGE_QID = "2"

def main
  if ARGV[0] == "--fetch"
    getResponses
  else
    getMesssage
  end
end

def getResponses
  uri = URI(
    "https://restapi.surveygizmo.com/v5/survey/#{SURVEY_ID}/surveyresponse?
    api_token=#{API_TOKEN}
    &api_token_secret=#{API_SECRET}"
  )

  response = Net::HTTP.get(uri)
  response_json = JSON.parse(response)
  formatted_responses = []

  response_json["data"].each do |x|
    response_hash = {
      "name" => x["survey_data"][NAME_QID]["answer"],
      "message" => x["survey_data"][MESSAGE_QID]["answer"]
    }

    formatted_responses.push(response_hash)
  end

  writeJson(formatted_responses)
end

def getMesssage
  if File.exist?(JSON_PATH)
    file = File.read(JSON_PATH)
    parsed_responses = JSON.parse(file)
    selected_response = parsed_responses.sample

    puts selected_response["message"], "\n", selected_response["name"]
  else
    puts "No file found.  Getting Response data."
    getResponses
  end
end

def writeJson(formatted_responses)
  File.open(JSON_PATH, "w") do |f|
    f.write(formatted_responses.to_json)
  end
end

main
