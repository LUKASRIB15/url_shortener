import { PutObjectCommand, S3Client } from "@aws-sdk/client-s3"
import {Handler} from "aws-lambda"
import { randomUUID } from "node:crypto"

export const handler: Handler = async (event: any) => {
  const client = new S3Client()
  const body = JSON.parse(event.body)

  try{
    const {original_url: originalUrl, expiration_time: expirationTime} = body

    if(!originalUrl || !expirationTime){
      throw new Error("Original url and  Expiration time must be defined.")
    }
  }catch(error: any){
    return {
      statusCode: 400,
      body: {
        message: error.message
      }
    }
  }
  
  const shortUrlCode = randomUUID()

  try{
    await client.send(
      new PutObjectCommand({
        Bucket: "lukasrib15-url-shortener-storage",
        Key: shortUrlCode + ".json",
        Body: JSON.stringify(body)
      })
    )
  }catch(error){
    throw new Error("Error saving data to S3: " + error)
  }

  const response = {
    statusCode: 200,
    body: {
      url_shortener: shortUrlCode
    }
  }

  return response
}
