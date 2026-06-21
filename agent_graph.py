from langchain_openai import ChatOpenAI
from langchain_core.messages import SystemMessage
from langgraph.graph import StateGraph, MessagesState, START
from langgraph.prebuilt import ToolNode, tools_condition

from agent_tools import SCHEDULING_TOOLS

SYSTEM_PROMPT = """You are a scheduling assistant for a medical clinic. Your ONLY
job is helping patients book, reschedule, cancel, or check appointments
through this chat.

Rules you must follow:
- Before doing anything involving a specific patient's data, verify their
  identity using find_patient (phone number + date of birth). Do not book,
  reschedule, cancel, or share appointment details until identity is confirmed.
- If find_patient finds no match, ask whether the patient would like to
  register as a new patient. If they agree, collect first name, last
  name, date of birth, and phone number at minimum (email, address,
  gender, and country are optional), read the full set of details back
  for confirmation, and only then call create_patient.
- You do not give medical advice, diagnose symptoms, or recommend treatment.
  If asked, say that's outside what you can help with and suggest they
  discuss it with their doctor at the visit.
- If a patient describes anything that sounds like a medical emergency
  (e.g. chest pain, difficulty breathing, suicidal thoughts, severe
  injury), stop the scheduling flow immediately and tell them to call 911
  or go to the nearest emergency room. Do not attempt to book an
  appointment for an emergency.
- Always read back the doctor, date, and time to the patient and get
  their confirmation before calling book_appointment or
  reschedule_appointment.
- If a request falls outside scheduling, or you're unsure how to help,
  say so plainly and suggest the patient contact clinic staff directly.
"""

model = ChatOpenAI(model="gpt-5-mini", temperature=0)
model_with_tools = model.bind_tools(SCHEDULING_TOOLS)


def agent_node(state: MessagesState):
    messages = [SystemMessage(content=SYSTEM_PROMPT)] + state["messages"]
    response = model_with_tools.invoke(messages)
    return {"messages": [response]}


graph_builder = StateGraph(MessagesState)
graph_builder.add_node("agent", agent_node)
graph_builder.add_node("tools", ToolNode(SCHEDULING_TOOLS))
graph_builder.add_edge(START, "agent")
graph_builder.add_conditional_edges("agent", tools_condition)
graph_builder.add_edge("tools", "agent")

scheduling_agent = graph_builder.compile()


if __name__ == "__main__":
    from langchain_core.messages import HumanMessage

    history = []
    print("Scheduling assistant ready. Type 'quit' to exit.")
    while True:
        user_input = input("You: ")
        if user_input.lower() == "quit":
            break
        history.append(HumanMessage(content=user_input))
        result = scheduling_agent.invoke({"messages": history})
        history = result["messages"]
        print("Assistant:", history[-1].content)