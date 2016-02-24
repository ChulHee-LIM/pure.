class SendMail < ApplicationMailer
    def auotomailer  address_to, m_subject, m_body
        mail from: address_to, 
               to: 'kty5989@gmail.com', 
          subject: m_subject, 
             body: m_body
    end
end
