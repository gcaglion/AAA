from tweepy import Stream
from tweepy import OAuthHandler
from tweepy.streaming import StreamListener

ckey    = 'aJuP1UqiIvRjAaPMbtOsFyker'
csecret = 'aAJH5iM77ppaEgAVqIa8BXy7MYISvyoZUUyiqL6NTaQ5vjRL6b'
atoken  = '3131497459-0G80eOPkosAc1UcKXlPmX2F1JA7Hg7uevT5C6wy'
asecret = 'xmOA1m8pd6jbaPibyNqmFYh8S9Z3nOMdf71ptQHXMKLYK'

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
twitterStream.filter(track=["eurusd", "bce", "fxcm", "FED"])

