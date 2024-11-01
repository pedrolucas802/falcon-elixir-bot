defmodule FalconBot do
  use Nostrum.Consumer
  alias Nostrum.Api

  @channel_id 1301390590575116341
  @api_key "key"
  @bible_id "id"
  @openai_api_key "key"
  @verses [
    "JER.29.11",
    "PSA.23",
    "1COR.4.4-8",
    "PHP.4.13",
    "JHN.3.16",
    "ROM.8.28",
    "ISA.41.10",
    "PSA.46.1",
    "GAL.5.22-23",
    "HEB.11.1",
    "2TI.1.7",
    "1COR.10.13",
    "PRO.22.6",
    "ISA.40.31",
    "JOS.1.9",
    "HEB.12.2",
    "MAT.11.28",
    "ROM.10.9-10",
    "PHP.2.3-4",
    "MAT.5.43-44",
    "PSA.37.4",
    "ISA.55.8-9",
    "JHN.14.6",
    "ROM.12.2",
    "JAS.1.5",
    "MAT.6.33",
    "EPH.2.8-9",
    "DEU.31.6",
    "1PET.5.7",
    "PRO.3.5-6",
    "MAT.19.26",
    "ISA.26.3",
    "JOS.24.15",
    "ROM.15.13",
    "LUK.1.37",
    "JHN.15.13",
    "PSA.27.1",
    "PSA.55.22",
    "HEB.13.8",
    "2COR.5.17",
    "EPH.6.10",
    "PHP.1.6",
    "COL.3.23",
    "1TH.5.16-18",
    "HEB.4.12",
    "ISA.43.2",
    "1PET.2.9",
    "ROM.5.8",
    "MAT.28.19-20"
  ]
    def start_link do
    Nostrum.Consumer.start_link(__MODULE__)
  end

  def handle_event({:READY, _data, _ws_state}) do
    send_startup_message()
  end

  defp send_startup_message do
    Api.create_message(@channel_id, """
    ✨ **Welcome aboard the Falcon!** ✨
    🚀 Type `!menu` to explore this galaxy!
    """)
  end


  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    cond do
      msg.content == "!ping" -> handle_ping(msg)
      msg.content == "!menu" -> display_menu(msg)
      true -> handle_simple_tools_command(msg)
    end
  end

  defp handle_simple_tools_command(msg) do
    cond do
      msg.content == "!coin" -> handle_coin_flip(msg)
      msg.content == "!dice" -> handle_dice_roll(msg)
      msg.content == "!count" -> handle_word_count(msg)
      true -> handle_api_tools_command(msg)
    end
  end

  defp handle_api_tools_command(msg) do
    cond do
      String.starts_with?(msg.content, "!verse") -> handle_random_verse(msg)
      String.starts_with?(msg.content, "!jarvis") -> handle_chatgpt_request(msg)
      String.starts_with?(msg.content, "!random_fact") -> handle_random_fact(msg)
      String.starts_with?(msg.content, "!meme") -> handle_random_meme(msg)
      true -> handle_extended_api_tools_command(msg)
    end
  end

  defp handle_extended_api_tools_command(msg) do
    cond do
      String.starts_with?(msg.content, "!currency") -> handle_currency_conversion(msg)
      String.starts_with?(msg.content, "!news") -> handle_news(msg)
      String.starts_with?(msg.content, "!joke") -> ask_joke_category(msg)
      String.starts_with?(msg.content, "!category") -> handle_joke_request(msg)
      true -> :ignore
    end
  end

  defp display_menu(msg) do
    api_menu = """
    Welcome aboard the Falcon!

    **API Command Menu:**
    1. `!jarvis <message>` - Ask something to ChatGPT.
    2. `!currency <amount> <from_currency> <to_currency>` - Convert currency values (Ex: 100 USD EUR).
    3. `!random_fact` - Get a random interesting fact.
    4. `!verse` - Be blessed by the word of the Lord.
    5. `!joke` - Get a random joke.
    6. `!meme` - Get a random meme.
    """

    non_api_menu = """
    **Non-API Command Menu:**
    1. `!ping` - Check if the bot is active.
    2. `!coin` - Flip a coin and get heads or tails.
    3. `!dice` - Roll a 6-sided dice and get the result.
    4. `!count <message>` - Count the number of words or characters in the message.
    """

    full_menu = api_menu <> "\n" <> non_api_menu
    Api.create_message(msg.channel_id, full_menu)
  end


  defp handle_ping(msg) do
    Api.create_message(msg.channel_id, "Hello there!")
    Api.create_message(msg.channel_id, "General Kenobi\nhttps://giphy.com/stickers/star-wars-general-kenobi-fruzsahercegno-c7HetN3VefdtxEk2QY")
  end


  defp handle_word_count(msg) do
    message_content = String.trim(String.replace_prefix(msg.content, "!api_count ", ""))

    word_count = length(String.split(message_content, ~r/\s+/))
    char_count = String.length(message_content)

    response = "The message has #{word_count} words and #{char_count} characters."
    Api.create_message(msg.channel_id, response)
  end


  defp handle_coin_flip(msg) do
    result = Enum.random(["heads", "tails"])
    Api.create_message(msg.channel_id, "The coin landed on: #{result}.")
  end

  defp handle_dice_roll(msg) do
    result = :rand.uniform(6)
    Api.create_message(msg.channel_id, "You rolled the dice and got: #{result}.")
  end

  defp handle_random_verse(msg) do
    verse_index = :rand.uniform(length(@verses)) - 1
    verse_id = Enum.at(@verses, verse_index)

    url = "https://api.scripture.api.bible/v1/bibles/#{@bible_id}/passages/#{verse_id}?content-type=text"

    headers = [{"api-key", @api_key}]

    case HTTPoison.get(url, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => %{"reference" => reference, "content" => content}}} ->
            verse_text = String.trim(content)
            Api.create_message(msg.channel_id, "**#{reference}**: #{verse_text}")

          _ ->
            Api.create_message(msg.channel_id, "Error processing the API response.")
        end

      {:ok, %HTTPoison.Response{status_code: 400}} ->
        Api.create_message(msg.channel_id, "Invalid parameter. Check Bible version compatibility with verse ID.")

      {:ok, %HTTPoison.Response{status_code: 403}} ->
        Api.create_message(msg.channel_id, "Not authorized. Check API key permissions.")

      {:ok, %HTTPoison.Response{status_code: 404}} ->
        Api.create_message(msg.channel_id, "Verse not found. Please try another verse.")

      {:error, _} ->
        Api.create_message(msg.channel_id, "Error. Please try again later.")
    end
  end

  defp handle_chatgpt_request(msg) do
    question = String.replace_prefix(msg.content, "!chatgpt ", "")

    url = "https://api.openai.com/v1/chat/completions"
    headers = [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{@openai_api_key}"}
    ]

    body = %{
      "model" => "gpt-4o-mini",
      "messages" => [
        %{"role" => "user", "content" => question}
      ],
      "max_tokens" => 150,
      "temperature" => 0.7
    }
    |> Jason.encode!()

    case HTTPoison.post(url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"choices" => [%{"message" => %{"content" => response}}]}} ->
            response_text = String.trim(response)
            Api.create_message(msg.channel_id, response_text)

          _ ->
            Api.create_message(msg.channel_id, "Error processing answer from ChatGPT.")
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Api.create_message(msg.channel_id, "Erro: #{status_code}")

      {:error, _} ->
        Api.create_message(msg.channel_id, "Error come back later.")
    end
  end

  defp ask_joke_category(msg) do
    category_message = """
    **Choose a joke category: **
    1 - any
    2 - Programming
    3 - Miscellaneous
    4 - Dark,
    5 - Pun
    6 - Spooky
    7 - Christmas.

    * Send the command `!category <category>` to receive a joke.

    WARNING: Not PG-13!
    """
    Api.create_message(msg.channel_id, category_message)
  end

  defp handle_joke_request(msg) do
    category = String.replace_prefix(msg.content, "!category ", "")
    url = "https://v2.jokeapi.dev/joke/#{category}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"type" => "single", "joke" => joke}} ->
            Api.create_message(msg.channel_id, joke)
          {:ok, %{"type" => "twopart", "setup" => setup, "delivery" => delivery}} ->
            Api.create_message(msg.channel_id, "#{setup}\n#{delivery}")
          _ ->
            Api.create_message(msg.channel_id, "Error processing the joke API response.")
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Api.create_message(msg.channel_id, "Error accessing the joke API. Status code: #{status_code}")

      {:error, _} ->
        Api.create_message(msg.channel_id, "Error trying to access the joke API. Please try again later.")
    end
  end

  defp handle_random_meme(msg) do
    url = "https://api.imgflip.com/get_memes"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"data" => %{"memes" => memes}}} when memes != [] ->
           meme = Enum.random(memes)
            response = "#{meme["name"]}: #{meme["url"]}"
            Api.create_message(msg.channel_id, response)

          _ ->
            Api.create_message(msg.channel_id, "No memes found.")
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Api.create_message(msg.channel_id, "Error accessing the memes API. Status code: #{status_code}")

      {:error, _} ->
        Api.create_message(msg.channel_id, "Error trying to access the memes API. Please try again later.")
    end
  end

  defp handle_news(msg) do
    category = String.replace_prefix(msg.content, "!news ", "")
    url = "https://newsapi.org/v2/top-headlines?category=#{category}&apiKey=YOUR_NEWS_API_KEY"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"articles" => articles}} when articles != [] ->
            [%{"title" => title, "url" => url}] = Enum.take(articles, 1)
            response = "**#{title}**\nRead more: #{url}"
            Api.create_message(msg.channel_id, response)

          _ ->
            Api.create_message(msg.channel_id, "No news articles found.")
        end

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Api.create_message(msg.channel_id, "Error accessing the news API. Status code: #{status_code}")

      {:error, _} ->
        Api.create_message(msg.channel_id, "Error trying to access the news API. Please try again later.")
    end
  end

  defp handle_random_fact(msg) do
    url = "http://numbersapi.com/random/trivia"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        Api.create_message(msg.channel_id, body)

      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Api.create_message(msg.channel_id, "Error accessing the facts API. Status code: #{status_code}")

      {:error, _} ->
        Api.create_message(msg.channel_id, "Error trying to access the facts API. Please try again later.")
    end
  end

  defp handle_currency_conversion(msg) do
    [_, amount_str, from_currency, to_currency] = String.split(msg.content)
    url = "https://api.exchangerate-api.com/v4/latest/#{from_currency}"

    case HTTPoison.get(url) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        process_currency_response(body, amount_str, from_currency, to_currency, msg)
      {:ok, %HTTPoison.Response{status_code: status_code}} ->
        Api.create_message(msg.channel_id, "Error accessing the currency API. Status code: #{status_code}")
      {:error, _} ->
        Api.create_message(msg.channel_id, "Error trying to access the currency API. Please try again later.")
    end
  end

  defp process_currency_response(body, amount_str, from_currency, to_currency, msg) do
    case Jason.decode(body) do
      {:ok, %{"rates" => rates}} ->
        rate = Map.get(rates, to_currency, nil)
        case Float.parse(amount_str) do
          {amount, _} when rate != nil ->
            converted_amount = amount * rate
            response = "#{amount_str} #{from_currency} is approximately #{converted_amount} #{to_currency}"
            Api.create_message(msg.channel_id, response)
          _ ->
            Api.create_message(msg.channel_id, "Invalid amount format: #{amount_str}.")
        end
      _ ->
        Api.create_message(msg.channel_id, "Error processing the currency API response.")
    end
  end

end
