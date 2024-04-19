from fastapi import FastAPI

app = FastAPI()   

@app.get("/") 
async def main():     
  return {"message": "Hey, it is me Goku"}