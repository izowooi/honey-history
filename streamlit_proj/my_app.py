# my_app.py
import streamlit as st

st.title("나의 멋진 Streamlit 웹사이트!")
st.write("Streamlit Community Cloud로 무료 배포하는 예시입니다.")

name = st.text_input("이름을 입력하세요:")
if name:
    st.write(f"안녕하세요, {name}님!")