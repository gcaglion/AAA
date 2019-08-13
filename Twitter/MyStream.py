from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener

ckey    = 'ZXzlHs2BAKbS5T0enojewbT8S'
csecret = 'NswmoNFw3TbyWbRkDKfSrKceOZHxCqQfPdhdOb3qHqGvN7UV8y'
atoken  = '3131497459-lMTQYj3YzJiU9irveBtLnaMP5CGLFcLcjbrE8Cz'
asecret = '1v7EP0kHIzBx35XTtwh1LrnzhC6btiJk2Lua9oYBhTPpU'

class listener(StreamListener):
	def on_data(self, data):
		#print data
		tweet = data.split(',"text":"')[1].split('","source')[0]
		print (tweet)
		return True
	
	def on_error(self, status):
		print (status)

def sentimentAnalysis(text):
	encoded_text = urllib.quote(text)
		
auth = OAuthHandler(ckey, csecret)
auth.set_access_token(atoken, asecret)
twitterStream = Stream(auth, listener())
twitterStream.filter(track=["eurusd"])

