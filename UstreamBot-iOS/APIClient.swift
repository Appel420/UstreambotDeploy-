
import Foundation



struct APIClient {

    static func sendMessage(prompt: String,

                            completion: @escaping (Result<String, Error>) -> Void) {

        guard let url = URL(string: "https://YOUR_BACKEND_URL/chat") else {

            completion(.failure(NSError(domain:"Invalid URL", code:0)))

            return

        }

        var req = URLRequest(url: url)

        req.httpMethod = "POST"

        req.addValue("application/json", forHTTPHeaderField: "Content-Type")

        req.httpBody = try? JSONSerialization

          .data(withJSONObject: ["prompt":prompt], options: [])



        URLSession.shared.dataTask(with: req) { data, _, err in

            if let e = err { return completion(.failure(e)) }

            guard let d = data,

                  let json = try? JSONSerialization

                    .jsonObject(with:d) as? [String:String],

                  let resp = json["response"]

            else {

                return completion(.failure(NSError(domain:"Bad response", code:1)))

            }

            completion(.success(resp))

        }.resume()

    }

}

