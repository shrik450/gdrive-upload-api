# Google Drive Upload API

A simple API to upload files to Google Drive.

## Setup

Run

```
bundle
```

to install gems.

A client secret is required to use this API. It can be obtained from the Google Developer console. Once you have set up an OAuth client in the console, download the Client secret json, name it `credentials.json` and include it at the root, next to `api.rb`.

## Use

Start the server by running:

```
ruby api.rb
```

By default, the server listens at `localhost:4567`.

You can use the root endpoint, `localhost:4567/` to get an OAuth key from google. Copy the OAuth key after giving the app permission. Then, you can send a POST request to `localhost:4567/upload` with a file and a `code` param with the OAuth key from the previous step. The following command will work:

```
curl -F "file=<FILEPATH>" -F "code=<OAUTH_CODE>;type=application/json" localhost:4567/upload
```

Where you should put the path to a file instead of `<FILEPATH>` and the OAuth Key instead of `<OAUTH_CODE>`.

The API will return a `422` response code in case the code or the file are not present, or if the file is of any content type other than `image/png`. The API does not rely on the content type given in the request; instead, the ruby library `MimeMagic` is used to verify the file type. If everything goes well, the API returns a `200` response code with a JSON body of the following type:

```
{
    file_link: <LINK_TO_FILE>
}
```

Where a link to the file will be in place of `<LINK_TO_FILE>`.
