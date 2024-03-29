//
//  LoginView.swift
//  SortMyPlaylist
//
//  Created by Coskun Deniz on 11/07/2020.
//

import SwiftUI
import BetterSafariView

struct LoginView: View {
    @EnvironmentObject var spotifyClient: SpotifyClient
    @EnvironmentObject var spotifyWebApi: SpotifyWebApi
    @State private var showItems = false
    @State private var showLoginPage = false
    @State var loginViewModel = LoginViewModel()
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: Color.App.azure, location: 0),
                    .init(color: Color.Spotify.black, location: 0.76),
                    .init(color: Color.Spotify.black, location: 1),
                ]),
                startPoint: UnitPoint(x: -0.67, y: -0.68),
                endPoint: UnitPoint(x: 1, y: 1)
            )
            VStack {
                ZStack {
                    Color.clear
                    VStack {
                        Text("Manage")
                            .foregroundColor(Color.App.capri)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)
                        Text("Your")
                            .foregroundColor(Color.App.mango)
                            .bold()
                            .frame(maxWidth: .infinity, alignment: .trailing)

                        Text("Playlists")
                            .bold()
                            .foregroundColor(Color.App.blueVelvet)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }.font(.system(size: 50)).padding(.bottom, 0).padding(.trailing, 30)
                }.shadow(radius: 10)

                ZStack {
                    Color.clear
                    VStack {
                        Button(action: login) {
                            HStack {
                                Image("Spotify_Icon_RGB_White").resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30)

                                Text("Log in with Spotify").foregroundColor(.white)
                            }.padding(EdgeInsets(top: 20, leading: 30, bottom: 20, trailing: 30))
                        }
                        .background(Capsule().foregroundColor(Color.Spotify.green))
                        Spacer()
                        Text("powered by Spotify")
                            .font(.callout)
                            .padding().foregroundColor(.white)
                    }
                    .transition(.opacity)
                }.frame(height: 250)
            }

        }.onAppear {
            withAnimation {
                self.showItems = true
            }
        }
        .webAuthenticationSession(isPresented: $showLoginPage) {
            WebAuthenticationSession(
                url: URL(string: url)!,
                callbackURLScheme: "sortmyplaylist"
            ) { callbackURL, error in

                if let url = callbackURL, let code = url.valueOf("code"){
                    loginViewModel.getAccessToken(code: code)
                }
            }
            .prefersEphemeralWebBrowserSession(false)
        }
    }
    
    
    var url: String {
        "https://accounts.spotify.com/authorize?response_type=code" +
            "&client_id=" + SpotifyClient.SpotifyClientID +
            "&scope=playlist-read-private,playlist-read-collaborative,playlist-modify-private,playlist-modify-public,user-library-read" +
            "&redirect_uri=\(SpotifyClient.SpotifyRedirectURI)"
    }
    
    func login() {
        showLoginPage.toggle()
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView().environmentObject(SpotifyClient()).edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/ .all/*@END_MENU_TOKEN@*/)
    }
}


