# frozen_string_literal: true

RSpec.describe(CheckWebsite) do
  subject(:worker) { CheckWebsite.new }

  describe '#perform' do
    subject(:perform) { worker.perform }

    context 'when the necessary env vars are set' do
      around do |spec|
        ClimateControl.modify(
          CHECK_WEBSITE_URL: check_website_url,
          X_CLIENT_ID: x_client_id,
        ) do
          spec.run
        end
      end

      let(:check_website_url) { 'https://api.retailer.com/' }
      let(:x_client_id) { SecureRandom.uuid }

      context 'when the response indicates the item is available' do
        before do
          stub_request(:get, check_website_url).
            with(
              headers: {
                'Accept' => 'application/json;version=2',
                'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
                'Accept-Language' => 'en-US,en;q=0.5',
                'User-Agent' => /Faraday .+/,
                'X-Client-Id' => x_client_id,
              },
            ).
            to_return(
              status: 200,
              headers: {
                'content-type' => 'application/json;version=2',
              },
              body: response_data.to_json,
            )
        end

        let(:response_data) do
          {
            'availabilities' => [
              {
                'availableForCashCarry' => false,
                'availableForClickCollect' => false,
                'buyingOption' => {
                  'cashCarry' => {
                    'availability' => {
                      'probability' => {
                        'thisDay' => {
                          'colour' => {
                            'rgbDec' => '224,7,81',
                            'rgbHex' => '#E00751',
                            'token' => 'colour-negative',
                          },
                          'messageType' => 'OUT_OF_STOCK',
                        },
                        'updateDateTime' => '2022-11-06T03:53:49.389Z',
                      },
                      'quantity' => 0,
                      'updateDateTime' => '2022-11-06T03:53:49.389Z',
                    },
                    'range' => {
                      'inRange' => true,
                    },
                    'unitOfMeasure' => 'PIECE',
                  },
                  'clickCollect' => {
                    'range' => {
                      'inRange' => true,
                    },
                  },
                  'homeDelivery' => {
                    'range' => {
                      'inRange' => true,
                    },
                  },
                },
                'classUnitKey' => {
                  'classUnitCode' => '010',
                  'classUnitType' => 'STO',
                },
                'itemKey' => {
                  'itemNo' => '50248541',
                  'itemType' => 'ART',
                },
              },
              {
                'availableForCashCarry' => true,
                'availableForClickCollect' => false,
                'buyingOption' => {
                  'cashCarry' => {
                    'availability' => {
                      'probability' => {
                        'thisDay' => {
                          'colour' => {
                            'rgbDec' => '224,7,81',
                            'rgbHex' => '#E00751',
                            'token' => 'colour-negative',
                          },
                          'messageType' => 'OUT_OF_STOCK',
                        },
                        'updateDateTime' => '2022-11-06T03:53:49.389Z',
                      },
                      'quantity' => 2,
                      'updateDateTime' => '2022-11-06T03:53:49.389Z',
                    },
                    'range' => {
                      'inRange' => true,
                    },
                    'unitOfMeasure' => 'PIECE',
                  },
                  'clickCollect' => {
                    'range' => {
                      'inRange' => true,
                    },
                  },
                  'homeDelivery' => {
                    'range' => {
                      'inRange' => true,
                    },
                  },
                },
                'classUnitKey' => {
                  'classUnitCode' => '410',
                  'classUnitType' => 'STO',
                },
                'itemKey' => {
                  'itemNo' => '50248541',
                  'itemType' => 'ART',
                },
              },
            ],
          }
        end

        it 'sends an email', queue_adapter: :test do
          expect { perform }.
            to enqueue_mail(CheckWebsiteMailer, :item_available).
            with(true, false, 2)
        end

        context 'when item is not available and restocks are planned' do
          let(:response_data) do
            data = super()
            availabilities = data['availabilities']
            availability = availabilities[1]
            availability['availableForCashCarry'] = false
            availability_detail = availability['buyingOption']['cashCarry']['availability']
            availability_detail['quantity'] = 0
            availability_detail['restocks'] = [{ 'date' => '2022-12-01' }]
            data
          end

          it 'sends an email', queue_adapter: :test do
            expect { perform }.
              to enqueue_mail(CheckWebsiteMailer, :restock_planned).
              with([{ date: '2022-12-01' }])
          end
        end
      end
    end
  end
end
