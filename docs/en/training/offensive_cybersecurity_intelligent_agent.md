# Offensive Cybersecurity Intelligent Agent

# Preface
In the latest version of viper, the Agent module driven by large models is introduced to assist network security engineers in red team simulation using viper. This article briefly introduces this new feature and analyzes the technical principles behind it.

# Intelligent Email Sender
## Actual Effect
+ It is possible to ask the agent relevant questions in a dialog manner.

![](img\offensive_cybersecurity_intelligent_agent\1.webp)

+ The agent can generate email content according to user needs.

![](img\offensive_cybersecurity_intelligent_agent\2.webp)

+ Support multi-round dialog and tool (API) calls.

![](img\offensive_cybersecurity_intelligent_agent\3.webp)

+ Final Effect

![](img\offensive_cybersecurity_intelligent_agent\4.webp)

When developing this agent, the following several problems are mainly solved:

+ Network security personnel are generally technical engineers. They generally do not know how to start writing phishing exercises. The aspect that large language models are best at is generating detailed articles based on users' brief needs. Phishing exercise emails become the initial application of large language models in offensive cybersecurity.
+ Generally, the more formal the email content is, the more trusted by the target. Most formal emails use HTML format to ensure correct formatting. The HTML generated by using large models can solve the problem of insufficient HTML skills of security engineers.
+ Combining large models with email sending API can realize the whole process of email generation, confirmation and sending through natural language dialog.

## Technical Description
Because the intelligent email sender has a clear purpose and a relatively fixed workflow, the focus in the development process is to describe the needs and processes as accurately as possible in the system prompt.

```shell
            agent_prompt.role = "Senior Email Writing Expert"
            agent_prompt.goal = "You help users generate and write email titles and contents, and can call APIs to send emails."
            agent_prompt.backstory = []
            agent_prompt.require_input = ["Email recipient", "A simple description of the main content of the email, such as `system notification`, `reward issuance`, etc.", "Download link of files in the email body"]
            agent_prompt.task_desc = ["Write email titles and contents according to user-provided information and send emails."]
            agent_prompt.task_requirement = [
                "The written email title and content must be in HTML format.",
                "The email is professional and meets business or government standards.",
                "The email content should include a prompt for the recipient to click the link in the body as soon as possible and download and execute.",
                "If the user only provides a very general description, you need to write a fictional email title and content to make the email look very formal and business. For example, if the user enters `system notification`, you need to write a detailed content (at least more than 500 words) to describe in detail that the company's XX system needs to be upgraded and needs to click the link to download and verify the file for identity verification. The email title should be `Company XXX System Upgrade Notice` (ensure more than 15 words).",
                "The content style should be close to system notification emails or emails sent by team departments, that is, you need to play the role of the sender of the email.",
                "If the content provided by the user may need to be sent by a specific department or system, the end of the email should be adapted according to the content provided by the user. For example, for `system notification`, it is generally sent by the IT operation and maintenance department in the company. For `reward issuance`, it is issued by the HR department. For example, if the user needs a `system notification` email, the end of the email should be `Best regards/n IT System Maintenance Team`. For example, if the user needs a `security check`, the end of the email is `Best regards/n Network Security Team"",
            ]
            agent_prompt.expected_output = "Professional and beautiful HTML format email"
            agent_prompt.reason_step = [
                "step 1: Write a required email title according to user input.",
                "step 2: Write a required email body according to user input.",
                "step 3: Write a beautiful HTML format email template and fill the email body into the template.",
                "step 4: Check task requirements one by one to ensure that the generated email content meets each requirement. Otherwise, go to step 1.",
                "step 5: Output formally"
            ]
            agent_prompt.notes = ["Get all necessary inputs before trying to call the API.", "Must get user's reply `send` to confirm before calling the API to send emails."]
```

In order to achieve the sending function, bind the email sending API to the model.

```shell
@tool
def send_mail_api(
        mail_to: Annotated[str, "Email recipient, such as: test@gmail.com"],
        mail_subject: Annotated[str, "Email title"],
        mail_content: Annotated[str, "Email content"],
        mail_content_subtype: Annotated[Literal['plain', 'html'], "Email content format"],
        mail_attachment_filenames: Annotated[list, "Email attachments, must be the file names in the `File Explorer`. The user needs to upload them to viper's `File Explorer` in advance"]
) -> Annotated[str, "Whether the email sending is successful"]:
    """
    Call the background API interface to send emails.
    Whenever the user or the platform needs to send an email, call this function.
    For example, the user asks 'Send the written email to test@gmail.com'
    """

tools = [
    llmfunc.send_mail_api,
]

llm_with_tools = self.llm.bind_to_tools(tools)

```

# Platform Operation Intelligent Agent
## Actual Effect
+ General conversation

![](img\offensive_cybersecurity_intelligent_agent\5.webp)

+ Natural language to view platform information

![](img\offensive_cybersecurity_intelligent_agent\6.webp)

+ Call APIs according to user needs and return the analyzed results

![](img\offensive_cybersecurity_intelligent_agent\7.webp)

## Technical Description
The platform operation intelligent agent is more like a general intelligent assistant or intelligent customer service. The purpose is that users can interact with the platform using natural language (instead of realizing specific needs).

The prompt words of this agent are relatively simple:

```shell
            agent_prompt.role = "Senior Network Security Red Team Expert"
            agent_prompt.goal = "Use provided tools and rich network security experience to complete tasks."
            agent_prompt.backstory = []
            agent_prompt.require_input = ["The goal that the user needs to achieve and the information that the user must provide."]
            agent_prompt.task_desc = ["Formulate a plan according to the user's needs and complete the task by calling platform tools."]
            agent_prompt.task_requirement = []
            agent_prompt.expected_output = "Complete plan and results after plan execution"
```

More functions are implemented through bound tools (that is, system APIs).

```shell
        tools = [
            llmfunc.function_call_debug,
            llmfunc.get_session_host_info,
            llmfunc.list_session,
            llmfunc.get_session_info,
            llmfunc.list_handler,
            llmfunc.list_host,
            llmfunc.list_route,
            llmfunc.query_route_by_ipaddress,
            llmfunc.session_meterpreter_run
        ]
```

Here are several functions listed:

```shell
@tool
def list_session() -> Annotated[str, "List of all alive sessions on the platform, in JSON format"]:
    """
    Return the list of current sessions and brief information of sessions on the platform.
    Whenever the user needs to obtain the configuration information of all sessions on the platform, call this function.
    For example, the user asks 'I need the session list of the platform'
    """

@tool
def list_handler() -> Annotated[str, "All handler (monitoring) configuration information on the platform, in JSON format"]:
    """
    Get all handler configuration information on the platform.
    Whenever the user needs to obtain the configuration information of the platform handler (monitoring), call this function.
    For example, the user asks 'I need all handler (monitoring) configurations'
    """

@tool
def query_route_by_ipaddress(
        ipaddress: Annotated[str, "The IP address to be queried, such as 10.10.10.10"],
) -> Annotated[str, "Routing configuration used by viper when connecting to the input IP, in JSON format"]:
    """
    Return the routing configuration used by the platform when connecting to this IP.
    Whenever the user needs to query the routing configuration of the platform when connecting to a certain IP, call this function.
    For example, the user asks 'Which session route does viper use when connecting to 10.10.10.10'
    """

```

It is necessary to clearly and explicitly explain the function description, return value, parameters, etc. and provide examples (that is, few shot in the industry) when necessary to improve the calling accuracy.