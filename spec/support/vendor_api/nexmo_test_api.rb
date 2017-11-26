# https://developer.nexmo.com/api/sms

module NexmoTestApi
  def self.stub_post_success
    WebMock.stub_request(:post, 'https://rest.nexmo.com/sms/json').
      to_return(
        status: 200,
        headers: {'Content-Type' => 'application/json'},
        body: JSON.dump(single_message_response),
      )
  end

  def self.single_message_response
    {
      'message-count' => '1',
      'messages' => [
        {
          'status' => '0',
          'message-id' => '00000123',
          'to' => '44123456789',
          'remaining-balance' => '1.10',
          'message-price' => '0.05',
          'network' => '23410',
        },
      ],
    }
  end
end
