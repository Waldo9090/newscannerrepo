import SwiftUI

struct OnboardingView1: View {
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 30) {
                    // Example Problem Card
                    VStack(alignment: .leading, spacing: 20) {
                        SectionTitle(title: "Smart Problem Solving", subtitle: "Get instant solutions with AI")
                        
                        ExampleProblemCard()
                    }
                    .padding(.top, 20)
                    
                    // Solution Demo
                    VStack(alignment: .leading, spacing: 20) {
                        SectionTitle(title: "Step-by-Step Solutions", subtitle: "Understand every step")
                        
                        SolutionDemoCard()
                    }
                }
                .padding(.horizontal)
            }
            
            // Bottom Section
            VStack(spacing: 20) {
                Text("Transform How You\nLearn & Study")
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding(.top, 30)
                
                Text("Get instant help for any academic question")
                    .font(.system(size: 17))
                    .foregroundColor(.gray)
                
                // Page Indicator
                PageIndicator(currentPage: 0, totalPages: 3)
                
                // Navigation Button
                NavigationLink(destination: OnboardingView2().navigationBarBackButtonHidden(true)) {
                    HStack {
                        Text("Continue")
                            .fontWeight(.semibold)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.purple.opacity(0.8))
                    .cornerRadius(30)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
            .background(Color.black)
        }
        .background(Color.black)
        .navigationBarHidden(true)
    }
}

struct ExampleProblemCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            ForEach(0..<3) { index in
                HStack(alignment: .top, spacing: 12) {
                    Text("\(index + 1).")
                        .foregroundColor(.gray)
                    
                    if index == 2 {
                        Text("Solve the quadratic equation: -4x² + 28x = 49")
                            .padding(.vertical, 5)
                            .padding(.horizontal, 8)
                            .background(Color.purple.opacity(0.2))
                            .cornerRadius(8)
                    } else {
                        Text(index == 0 ? "Find the solution of 3x² - 2x + 1 = 0" : "If a and b are solutions to (2x + 3)(3x - 1) = 7, find |a| + |b|")
                    }
                }
                .font(.system(size: 16))
                .foregroundColor(.white)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
    }
}

struct SolutionDemoCard: View {
    var body: some View {
        HStack(spacing: 15) {
            Image("SolvoLogo")
                .resizable()
                .frame(width: 40, height: 40)
                .background(Color.purple)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Step-by-Step Solution")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("x = 7/2")
                    .font(.system(size: 16, weight: .medium))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.3))
                    .cornerRadius(8)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(20)
    }
}

struct OnboardingView1_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView1()
    }
} 