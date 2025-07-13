import { GetObjectCommand, S3Client } from "@aws-sdk/client-s3"
import {Handler} from "aws-lambda"

export const handler: Handler = async (event: any) => {
  const rawPath = event.path

  const shortUrlCode = rawPath.replace('/', '')
  const client = new S3Client({
    region: "sa-east-1"
  })

  if(!shortUrlCode || shortUrlCode === ""){
    throw new Error("Invalid input: 'shortUrlCode' must be defined.")
  }

  try{
    const response = await client.send(
      new GetObjectCommand({
        Bucket: "<your_bucket_name>",
        Key: shortUrlCode + ".json"
      })
    )

    if(response.Body){
      const bodyAsString = await response.Body.transformToString("utf-8")
      const bodyAsJson = JSON.parse(bodyAsString)

      try{
        const {original_url: originalUrl, expiration_time: expirationTime} = bodyAsJson

        if(!originalUrl || !expirationTime){
          throw new Error("Original url and Expiration time must be defined.")
        }

        const currentTime = new Date().getTime() / 1000 // current time in seconds

        if(currentTime < Number(expirationTime)){
          const response = {
            statusCode: 302,
            headers: {
              location: originalUrl
            }
          }

          return response
        } else {
          const response = {
            statusCode: 410,
            body: JSON.stringify({
              message: "This URL has expired."
            })
          }

          return response
        }
      }catch(error: any){
        return {
          statusCode: 400,
          body: JSON.stringify({
            message: error.message
          })
        }
      }
    }
  }catch(error){
    throw new Error("Error getting data of S3: " + error)
  }
}