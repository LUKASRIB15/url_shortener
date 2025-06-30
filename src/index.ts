import {Handler} from "aws-lambda"
import { randomUUID } from "node:crypto"

export const handler: Handler = async (event: any) => {

  console.log("EVENT HANDLER ->", JSON.parse(event.body))
  
  const shortUrl = randomUUID()

  const response = {
    statusCode: 200,
    body: {
      url_shortener: shortUrl
    }
  }

  return response
}
