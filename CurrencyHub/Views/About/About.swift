//
//  About.swift
//  CurrencyHub
//
//  Created by Abylaykhan Myrzakhanov on 20.01.2024.
//

import SwiftUI

struct About: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                Image(systemName: "building.columns.fill")
                    .foregroundStyle(.white)
                    .font(.system(size: 60))
                    .padding()
                    .background(.blue.opacity(0.8))
                    .clipShape(.circle)
                VStack(alignment: .leading, spacing: 10) {
                    Label(
                        title: { Text("goal_of_application").foregroundStyle(.primary) },
                        icon: { Image(systemName: "graduationcap.circle.fill").foregroundStyle(.brown) }
                    )
                    .padding(.horizontal)
                    HStack {
                        Text("goal_of_application_description")
                            .font(.system(size: 16))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal)
                    Label(
                        title: { Text("about_app_improvements").foregroundStyle(.primary) },
                        icon: { Image(systemName: "link.circle.fill").foregroundStyle(.brown) }
                    )
                    .padding(.horizontal)
                    HStack {
                        Text("about_app_improve_description")
                            .font(.system(size: 16))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal)
                    Label(
                        title: { Text("about_app_contacts").foregroundStyle(.primary) },
                        icon: { Image(systemName: "envelope.circle.fill").foregroundStyle(.brown) }
                    )
                    .padding(.horizontal)
                    HStack {
                        Text("E-mail: CreateNewX@gmail.com")
                            .font(.system(size: 16))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal)
                    Label(
                        title: { Text("about_app_charity").foregroundStyle(.primary) },
                        icon: { Image(systemName: "bolt.horizontal.circle.fill").foregroundStyle(.brown) }
                    )
                    .padding(.horizontal)
                    VStack {
                        HStack {
                            Image(systemName: "bitcoinsign.circle")
                                .foregroundStyle(.orange)
                            Text("1DXQMCET2FXgBWGYvNMAAWHU71ipHJL3Rw")
                                .font(.system(size: 13))
                            Spacer()
                        }
                        
                        Button {
                            
                        } label: {
                            Text("about_app_sub")
                        }
                        .frame(width: 275)
                        .padding(.all, 10)
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 15))
                        .padding(.top, 5)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .padding(.horizontal)
                }
                HStack {
                    Text("about_app_sub_description")
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .font(.system(size: 16))
                .background(Color.gray.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .padding(.horizontal)
                .foregroundStyle(.blue)
            }
            .navigationTitle("about_of_application")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    About()
}
