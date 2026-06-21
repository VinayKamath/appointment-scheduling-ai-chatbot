import streamlit as st
from langchain_core.messages import AIMessage, HumanMessage

from agent_graph import scheduling_agent

st.set_page_config(page_title="Appointment Scheduling Assistant", page_icon="🗓️")
st.title("🗓️ Appointment Scheduling Assistant")
st.caption("Book, reschedule, or cancel an appointment. For medical questions, please contact your provider directly.")

if "messages" not in st.session_state:
    st.session_state.messages = []

for msg in st.session_state.messages:
    if isinstance(msg, HumanMessage):
        with st.chat_message("user"):
            st.write(msg.content)
    elif isinstance(msg, AIMessage) and msg.content:
        with st.chat_message("assistant"):
            st.write(msg.content)

user_input = st.chat_input("Ask about booking, rescheduling, or cancelling an appointment...")

if user_input:
    st.session_state.messages.append(HumanMessage(content=user_input))
    with st.chat_message("user"):
        st.write(user_input)

    with st.chat_message("assistant"):
        with st.spinner("Thinking..."):
            result = scheduling_agent.invoke({"messages": st.session_state.messages})

        st.session_state.messages = result["messages"]

        final_reply = next(
            (m.content for m in reversed(result["messages"]) if isinstance(m, AIMessage) and m.content),
            "I'm not sure how to respond to that.",
        )
        st.write(final_reply)