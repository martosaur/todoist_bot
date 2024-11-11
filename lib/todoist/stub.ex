defmodule TodoistBot.Todoist.API.Stub do
  @behaviour TodoistBot.Todoist.API

  @impl true
  def request(%{url: %URI{path: "oauth/access_token"}}) do
    {:ok,
     %Req.Response{
       status: 200,
       headers: %{
         "cache-control" => ["no-store"],
         "connection" => ["keep-alive"],
         "content-type" => ["application/json; charset=UTF-8"],
         "date" => ["Sun, 10 Nov 2024 17:56:42 GMT"],
         "pragma" => ["no-cache"],
         "referrer-policy" => ["strict-origin-when-cross-origin"],
         "server" => ["gunicorn"],
         "set-cookie" => [
           "csrf=12ffc5642a4040af96a7a859bb048c0d; Expires=Wed, 08-Nov-2034 17:56:42 GMT; Secure; Path=/; SameSite=None",
           "todoistd=\"/CUdA09psYiwY7pwgn9sRGC/RQQ=?\"; Domain=.todoist.com; Expires=Mon, 10-Nov-2025 17:56:42 GMT; Max-Age=31536000; Secure; HttpOnly; Path=/; SameSite=None"
         ],
         "strict-transport-security" => ["max-age=31536000; includeSubDomains; preload"],
         "vary" => ["Accept-Encoding"],
         "via" => ["1.1 72ba5a35cd84ad30e4fd5bf87d23ed86.cloudfront.net (CloudFront)"],
         "x-amz-cf-id" => ["4NEiQWm5obaZz-P71NMa7PDiSEG75HkjYE2S-V2ha74aX23NKo-Dlw=="],
         "x-amz-cf-pop" => ["YVR52-P1"],
         "x-cache" => ["Miss from cloudfront"]
       },
       body: %{
         "access_token" => "helloworldmytoken",
         "token_type" => "Bearer"
       },
       trailers: %{},
       private: %{}
     }}
  end

  def request(%{url: %URI{path: "rest/v2/tasks"}}) do
    {:ok,
     %Req.Response{
       status: 200,
       headers: %{
         "access-control-allow-credentials" => ["false"],
         "access-control-allow-origin" => ["*"],
         "cache-control" => ["no-cache"],
         "connection" => ["keep-alive"],
         "content-type" => ["application/json"],
         "date" => ["Sun, 10 Nov 2024 18:13:44 GMT"],
         "referrer-policy" => ["strict-origin-when-cross-origin"],
         "server" => ["gunicorn"],
         "set-cookie" => [
           "csrf=662be05a6a4b4cbf90bdc351a094dbd1; Expires=Wed, 08-Nov-2034 18:13:44 GMT; Secure; Path=/; SameSite=None",
           "tduser=v4.public.eyJ1c2VyX2lkIjogMTk2MzE4MSwgImV4cCI6ICIyMDI0LTExLTI0VDE4OjEzOjQ0KzAwOjAwIn0t8eAcBnYkTOBLw54z8PYmjmhtOtIncPGzLIaykMEFj04_SUpr0zHpa42zCzsG0ezKN1v1YIrnHjhnksXLtKEB; Domain=.todoist.com; Expires=Sun, 24-Nov-2024 18:13:44 GMT; Max-Age=1209600; Secure; HttpOnly; Path=/",
           "todoistd=\"/CUdA09psYiwY7pwgn9sRGC/RQQ=?\"; Domain=.todoist.com; Expires=Mon, 10-Nov-2025 18:13:44 GMT; Max-Age=31536000; Secure; HttpOnly; Path=/; SameSite=None"
         ],
         "strict-transport-security" => ["max-age=31536000; includeSubDomains; preload"],
         "vary" => ["Accept-Encoding"],
         "via" => ["1.1 48e357a9c6dfc82d172c94f2bb89300e.cloudfront.net (CloudFront)"],
         "x-amz-cf-id" => ["2wDBpLT-hmwu07bRitoOxnQquFnvx83XdJ-NRmLrWjHuKtuZBWFqPw=="],
         "x-amz-cf-pop" => ["YVR52-P1"],
         "x-cache" => ["Miss from cloudfront"]
       },
       body: %{
         "assignee_id" => nil,
         "assigner_id" => nil,
         "comment_count" => 0,
         "content" => "FOo Bar",
         "created_at" => "2024-11-10T18:13:44.226086Z",
         "creator_id" => "1963181",
         "deadline" => nil,
         "description" => "",
         "due" => nil,
         "duration" => nil,
         "id" => "8574301043",
         "is_completed" => false,
         "labels" => [],
         "order" => 20,
         "parent_id" => nil,
         "priority" => 1,
         "project_id" => "2002142158",
         "section_id" => nil,
         "url" => "https://app.todoist.com/app/task/8574301043"
       },
       trailers: %{},
       private: %{}
     }}
  end
end
